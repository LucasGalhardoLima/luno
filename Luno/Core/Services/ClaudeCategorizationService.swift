import Foundation
import os

// MARK: - Claude Categorization Service

// Claude API-based cloud categorization for PARA method
// Constitution: Cloud fallback when on-device confidence is below threshold

actor ClaudeCategorizationService: CategorizationServiceProtocol {
    // MARK: - Properties

    private let log = LunoLogger.network
    private let config: CategorizationConfig
    private let urlSession: URLSession

    // MARK: - Initialization

    init(
        config: CategorizationConfig = CategorizationConfig(),
        urlSession: URLSession = .shared
    ) {
        self.config = config
        self.urlSession = urlSession
    }

    // MARK: - CategorizationServiceProtocol

    var isAvailable: Bool {
        get async { !config.claudeApiKey.isEmpty }
    }

    func checkAvailability() async -> CategorizationAvailability {
        guard !config.claudeApiKey.isEmpty else {
            return .unavailable(reason: .noApiKey)
        }
        return .available
    }

    func categorize(_ content: String) async throws -> CategorizationResult {
        // Validate
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw CategorizationError.invalidContent(reason: "Content cannot be empty")
        }

        guard !config.claudeApiKey.isEmpty else {
            log.error("Claude API key not configured")
            throw CategorizationError.serviceUnavailable(reason: .noApiKey)
        }

        log.info("Sending categorization request to Claude API")

        // Build request
        let prompt = buildCategorizationPrompt(for: trimmed)
        let request = try buildRequest(prompt: prompt, noteContent: trimmed)

        // Execute
        let (data, response) = try await urlSession.data(for: request)

        // Handle HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            log.error("Invalid response type from Claude API")
            throw CategorizationError.networkError(message: "Invalid response type")
        }

        log.debug("Claude API responded with status: \(httpResponse.statusCode)")

        switch httpResponse.statusCode {
        case 200:
            return try parseAPIResponse(data)
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "retry-after")
                .flatMap { TimeInterval($0) }
            log.warning("Claude API rate limited, retry after: \(retryAfter ?? 0)s")
            throw CategorizationError.rateLimited(retryAfter: retryAfter)
        case 401:
            log.error("Claude API authentication failed - invalid API key")
            throw CategorizationError.apiError(statusCode: 401, message: "Invalid API key")
        default:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            log.error("Claude API error (\(httpResponse.statusCode)): \(message)")
            throw CategorizationError.apiError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    // MARK: - Prompt Building (internal for testing)

    nonisolated func buildCategorizationPrompt(for content: String) -> String {
        """
        Categorize the following note into one of the PARA method categories. \
        The PARA method organizes information into:

        - **project**: Short-term efforts with a specific deadline and outcome. \
        Examples: "Finish website redesign by Friday", "Prepare Q4 presentation"
        - **area**: Ongoing responsibilities that require regular maintenance. \
        Examples: "Weekly health check-in", "Monthly budget review"
        - **resource**: Reference materials, topics of interest, or knowledge. \
        Examples: "Great article about SwiftUI", "Useful cooking technique"
        - **archive**: Completed, inactive, or no longer relevant items. \
        Examples: "Finished the marketing campaign", "Old project notes"

        Respond ONLY with a valid JSON object in this exact format:
        {
            "category": "<project|area|resource|archive>",
            "reasoning": "<one sentence explaining why this category was chosen>",
            "confidence": <0.0 to 1.0>
        }

        Note content:
        \"\"\"\(content)\"\"\"
        """
    }

    // MARK: - Request Building

    private func buildRequest(prompt: String, noteContent _: String) throws -> URLRequest {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw CategorizationError.unknown(message: "Invalid API URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.claudeApiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = config.timeout

        let body: [String: Any] = [
            "model": config.claudeModel,
            "max_tokens": 256,
            "messages": [
                [
                    "role": "user",
                    "content": prompt,
                ],
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    // MARK: - Response Parsing

    private func parseAPIResponse(_ data: Data) throws -> CategorizationResult {
        // Parse the Claude API response structure
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String
        else {
            throw CategorizationError.unknown(message: "Unexpected API response format")
        }

        return try parseCategorizationResponse(text)
    }

    /// Parse the categorization JSON response (internal for testing)
    nonisolated func parseCategorizationResponse(_ jsonString: String) throws -> CategorizationResult {
        // Extract JSON from the response (handle potential markdown wrapping)
        let cleanJSON = extractJSON(from: jsonString)

        guard let data = cleanJSON.data(using: .utf8) else {
            throw CategorizationError.unknown(message: "Failed to encode JSON string")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CategorizationError.unknown(message: "Invalid JSON structure")
        }

        guard let categoryString = json["category"] as? String else {
            throw CategorizationError.unknown(message: "Missing 'category' field in response")
        }

        let category = PARACategory(rawValue: categoryString) ?? .uncategorized
        let reasoning = json["reasoning"] as? String ?? "No reasoning provided"
        let rawConfidence = json["confidence"] as? Double ?? 0.5

        // Clamp confidence to valid range
        let confidence = min(max(rawConfidence, 0.0), 1.0)

        return CategorizationResult(
            category: category,
            reasoning: reasoning,
            confidence: confidence
        )
    }

    /// Extracts JSON object from a string that may contain markdown formatting
    nonisolated private func extractJSON(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove markdown code blocks if present
        if trimmed.hasPrefix("```") {
            let lines = trimmed.components(separatedBy: "\n")
            let jsonLines = lines.dropFirst().dropLast().joined(separator: "\n")
            return jsonLines.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return trimmed
    }
}
