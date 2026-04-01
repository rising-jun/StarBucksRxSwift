enum NetworkError: Error {
    case invaliedRequestURL
    case nilData
    case URLSessionError(error: Error)
}
