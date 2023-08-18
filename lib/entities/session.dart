import 'tokens.dart';

class Session {
  Tokens? tokens;

  Session({this.tokens});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(tokens: Tokens.fromJson(json['tokens']));
  }

  Map<String, dynamic> toJson() => {
        'tokens': tokens?.toJson(),
      };
}
