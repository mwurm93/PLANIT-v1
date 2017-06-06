//  This file was automatically generated and should not be edited.

import Apollo

public struct CreateUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(password: String, username: String, clientMutationId: GraphQLID? = nil) {
    graphQLMap = ["password": password, "username": username, "clientMutationId": clientMutationId]
  }
}

public final class CreateUserMutation: GraphQLMutation {
  public static let operationDefinition =
    "mutation CreateUser($user: CreateUserInput!) {" +
    "  createUser(input: $user) {" +
    "    __typename" +
    "    changedUser {" +
    "      __typename" +
    "      id" +
    "      username" +
    "    }" +
    "    token" +
    "  }" +
    "}"

  public let user: CreateUserInput

  public init(user: CreateUserInput) {
    self.user = user
  }

  public var variables: GraphQLMap? {
    return ["user": user]
  }

  public struct Data: GraphQLMappable {
    /// Create objects of type User.
    public let createUser: CreateUser?

    public init(reader: GraphQLResultReader) throws {
      createUser = try reader.optionalValue(for: Field(responseName: "createUser", arguments: ["input": reader.variables["user"]]))
    }

    public struct CreateUser: GraphQLMappable {
      public let __typename: String
      /// The mutated User.
      public let changedUser: ChangedUser?
      /// The user's authentication token. Embed this under the
      /// 'Authorization' header with the format 'Bearer <token>'
      /// 
      public let token: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        changedUser = try reader.optionalValue(for: Field(responseName: "changedUser"))
        token = try reader.optionalValue(for: Field(responseName: "token"))
      }

      public struct ChangedUser: GraphQLMappable {
        public let __typename: String
        /// A globally unique ID.
        public let id: GraphQLID
        /// The user's username.
        public let username: String

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.value(for: Field(responseName: "id"))
          username = try reader.value(for: Field(responseName: "username"))
        }
      }
    }
  }
}