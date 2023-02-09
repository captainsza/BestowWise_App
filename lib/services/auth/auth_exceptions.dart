// LOgin Exceptions
class UserNOtFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Register exception
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUSeAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// Generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
