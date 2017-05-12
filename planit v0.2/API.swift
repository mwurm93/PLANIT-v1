//  This file was automatically generated and should not be edited.

import Apollo

public struct CreateUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(userGender: Gender? = nil, userPassportNumber: Int? = nil, username: String, password: String, userKnownTravelerNumber: Int? = nil, lastName: String? = nil, userTelephone: Int? = nil, userBirthDate: Int? = nil, userHomeAirport: String? = nil, firstName: String? = nil, userRedressNumber: Int? = nil, clientMutationId: String? = nil) {
    graphQLMap = ["userGender": userGender, "userPassportNumber": userPassportNumber, "username": username, "password": password, "userKnownTravelerNumber": userKnownTravelerNumber, "lastName": lastName, "userTelephone": userTelephone, "userBirthDate": userBirthDate, "userHomeAirport": userHomeAirport, "firstName": firstName, "userRedressNumber": userRedressNumber, "clientMutationId": clientMutationId]
  }
}

/// Values for the Gender enum
public enum Gender: String {
  case male = "Male"
  case female = "Female"
}

extension Gender: JSONDecodable, JSONEncodable {}

public final class CreateAUserMutation: GraphQLMutation {
  public static let operationDefinition =
    "mutation CreateAUser($newUser: CreateUserInput!) {" +
    "  createUser(input: $newUser) {" +
    "    __typename" +
    "    token" +
    "    changedUser {" +
    "      __typename" +
    "      id" +
    "      username" +
    "      createdAt" +
    "    }" +
    "  }" +
    "}"

  public let newUser: CreateUserInput

  public init(newUser: CreateUserInput) {
    self.newUser = newUser
  }

  public var variables: GraphQLMap? {
    return ["newUser": newUser]
  }

  public struct Data: GraphQLMappable {
    /// Create objects of type User.
    public let createUser: CreateUser?

    public init(reader: GraphQLResultReader) throws {
      createUser = try reader.optionalValue(for: Field(responseName: "createUser", arguments: ["input": reader.variables["newUser"]]))
    }

    public struct CreateUser: GraphQLMappable {
      public let __typename: String
      /// The user's authentication token. Embed this under the
      /// 'Authorization' header with the format 'Bearer <token>'
      /// 
      public let token: String?
      /// The mutated User.
      public let changedUser: ChangedUser?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        token = try reader.optionalValue(for: Field(responseName: "token"))
        changedUser = try reader.optionalValue(for: Field(responseName: "changedUser"))
      }

      public struct ChangedUser: GraphQLMappable {
        public let __typename: String
        /// A globally unique ID.
        public let id: GraphQLID
        /// The user's username.
        public let username: String
        /// When paired with the Node interface, this is an automatically managed
        /// timestamp that is set when an object is first created.
        public let createdAt: String

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.value(for: Field(responseName: "id"))
          username = try reader.value(for: Field(responseName: "username"))
          createdAt = try reader.value(for: Field(responseName: "createdAt"))
        }
      }
    }
  }
}

public final class GetTripQuery: GraphQLQuery {
  public static let operationDefinition =
    "query GetTrip($id: ID!) {" +
    "  getTrip(id: $id) {" +
    "    __typename" +
    "    id" +
    "    name" +
    "    users {" +
    "      __typename" +
    "      edges {" +
    "        __typename" +
    "        cursor" +
    "        node {" +
    "          __typename" +
    "          id" +
    "          username" +
    "        }" +
    "        budget" +
    "      }" +
    "    }" +
    "  }" +
    "}"

  public let id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLMappable {
    /// Get objects of type Trip by id.
    public let getTrip: GetTrip?

    public init(reader: GraphQLResultReader) throws {
      getTrip = try reader.optionalValue(for: Field(responseName: "getTrip", arguments: ["id": reader.variables["id"]]))
    }

    public struct GetTrip: GraphQLMappable {
      public let __typename: String
      /// A globally unique ID.
      public let id: GraphQLID
      public let name: String
      public let users: User?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        id = try reader.value(for: Field(responseName: "id"))
        name = try reader.value(for: Field(responseName: "name"))
        users = try reader.optionalValue(for: Field(responseName: "users"))
      }

      public struct User: GraphQLMappable {
        public let __typename: String
        /// The set of edges in this page.
        public let edges: [Edge?]?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          edges = try reader.optionalList(for: Field(responseName: "edges"))
        }

        public struct Edge: GraphQLMappable {
          public let __typename: String
          /// An opaque cursor pointing to an object in a connection.
          /// Used by the 'after' and 'before' pagination arguments.
          public let cursor: String
          /// The node value for the edge.
          public let node: Node
          public let budget: Int?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            cursor = try reader.value(for: Field(responseName: "cursor"))
            node = try reader.value(for: Field(responseName: "node"))
            budget = try reader.optionalValue(for: Field(responseName: "budget"))
          }

          public struct Node: GraphQLMappable {
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
  }
}