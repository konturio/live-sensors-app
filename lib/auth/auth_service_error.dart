class AuthServiceError extends Error {

}

class NotAuthorized extends AuthServiceError {

}
class NeverAuthorized extends AuthServiceError {

}
class LoginError extends AuthServiceError {

}


