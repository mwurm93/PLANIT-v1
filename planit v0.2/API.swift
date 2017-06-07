//  This file was automatically generated and should not be edited.

import Apollo

public struct CreateUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(password: String, username: String, clientMutationId: GraphQLID? = nil) {
    graphQLMap = ["password": password, "username": username, "clientMutationId": clientMutationId]
  }
}

public struct CreateTripInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(tripName: String, clientMutationId: GraphQLID? = nil) {
    graphQLMap = ["tripName": tripName, "clientMutationId": clientMutationId]
  }
}

/// Where filter arguments for the User type
public struct UserWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(modifiedAt: UserModifiedAtWhereArgs? = nil, trips: UserTripsWhereArgs? = nil, messages: MessageWhereArgs? = nil, roles: UserRolesWhereArgs? = nil, lastLogin: UserLastLoginWhereArgs? = nil, id: UserIdWhereArgs? = nil, password: UserPasswordWhereArgs? = nil, username: UserUsernameWhereArgs? = nil, createdAt: UserCreatedAtWhereArgs? = nil, or: [UserWhereArgs?]? = nil, and: [UserWhereArgs?]? = nil) {
    graphQLMap = ["modifiedAt": modifiedAt, "trips": trips, "messages": messages, "roles": roles, "lastLogin": lastLogin, "id": id, "password": password, "username": username, "createdAt": createdAt, "OR": or, "AND": and]
  }
}

public struct UserModifiedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Select objects by filtering on objects in a connection
public struct UserTripsWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(edge: ManyTripsToManyUsersEdgeWhereArgs? = nil, node: TripWhereArgs? = nil) {
    graphQLMap = ["edge": edge, "node": node]
  }
}

/// Where filter arguments for the manyTripsToManyUsers type
public struct ManyTripsToManyUsersEdgeWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(modifiedAt: ManyTripsToManyUsersModifiedAtWhereArgs? = nil, createdAt: ManyTripsToManyUsersCreatedAtWhereArgs? = nil) {
    graphQLMap = ["modifiedAt": modifiedAt, "createdAt": createdAt]
  }
}

public struct ManyTripsToManyUsersModifiedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct ManyTripsToManyUsersCreatedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Where filter arguments for the Trip type
public struct TripWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(tripName: TripTripNameWhereArgs? = nil, messages: MessageWhereArgs? = nil, id: TripIdWhereArgs? = nil, modifiedAt: TripModifiedAtWhereArgs? = nil, users: TripUsersWhereArgs? = nil, createdAt: TripCreatedAtWhereArgs? = nil, or: [TripWhereArgs?]? = nil, and: [TripWhereArgs?]? = nil) {
    graphQLMap = ["tripName": tripName, "messages": messages, "id": id, "modifiedAt": modifiedAt, "users": users, "createdAt": createdAt, "OR": or, "AND": and]
  }
}

public struct TripTripNameWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Where filter arguments for the message type
public struct MessageWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: MessageIdWhereArgs? = nil, author: UserWhereArgs? = nil, modifiedAt: MessageModifiedAtWhereArgs? = nil, trip: TripWhereArgs? = nil, contentString: MessageContentStringWhereArgs? = nil, createdAt: MessageCreatedAtWhereArgs? = nil, authorId: MessageAuthorIdWhereArgs? = nil, tripId: MessageTripIdWhereArgs? = nil, or: [MessageWhereArgs?]? = nil, and: [MessageWhereArgs?]? = nil) {
    graphQLMap = ["id": id, "author": author, "modifiedAt": modifiedAt, "trip": trip, "contentString": contentString, "createdAt": createdAt, "authorId": authorId, "tripId": tripId, "OR": or, "AND": and]
  }
}

public struct MessageIdWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: GraphQLID? = nil, ne: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "in": `in`, "notIn": notIn, "isNull": isNull]
  }
}

public struct MessageModifiedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct MessageContentStringWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct MessageCreatedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct MessageAuthorIdWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: GraphQLID? = nil, ne: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "in": `in`, "notIn": notIn, "isNull": isNull]
  }
}

public struct MessageTripIdWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: GraphQLID? = nil, ne: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "in": `in`, "notIn": notIn, "isNull": isNull]
  }
}

public struct TripIdWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: GraphQLID? = nil, ne: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "in": `in`, "notIn": notIn, "isNull": isNull]
  }
}

public struct TripModifiedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Select objects by filtering on objects in a connection
public struct TripUsersWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(edge: ManyTripsToManyUsersEdgeWhereArgs? = nil, node: UserWhereArgs? = nil) {
    graphQLMap = ["edge": edge, "node": node]
  }
}

public struct TripCreatedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Select objects by filtering on objects in a connection
public struct UserRolesWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(edge: UserRolesEdgeWhereArgs? = nil, node: RoleWhereArgs? = nil) {
    graphQLMap = ["edge": edge, "node": node]
  }
}

/// Where filter arguments for the UserRoles type
public struct UserRolesEdgeWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(accessLevel: UserRolesAccessLevelWhereArgs? = nil, createdAt: UserRolesCreatedAtWhereArgs? = nil, modifiedAt: UserRolesModifiedAtWhereArgs? = nil) {
    graphQLMap = ["accessLevel": accessLevel, "createdAt": createdAt, "modifiedAt": modifiedAt]
  }
}

public struct UserRolesAccessLevelWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: AccessLevel? = nil, ne: AccessLevel? = nil, gt: AccessLevel? = nil, gte: AccessLevel? = nil, lt: AccessLevel? = nil, lte: AccessLevel? = nil, between: [AccessLevel?]? = nil, notBetween: [AccessLevel?]? = nil, `in`: [AccessLevel?]? = nil, notIn: [AccessLevel?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Values for the AccessLevel enum
public enum AccessLevel: String {
  case admin = "admin"
  case readwrite = "readwrite"
  case readonly = "readonly"
}

extension AccessLevel: JSONDecodable, JSONEncodable {}

public struct UserRolesCreatedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct UserRolesModifiedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

/// Where filter arguments for the Role type
public struct RoleWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(members: RoleMembersWhereArgs? = nil, createdAt: RoleCreatedAtWhereArgs? = nil, modifiedAt: RoleModifiedAtWhereArgs? = nil, id: RoleIdWhereArgs? = nil, name: RoleNameWhereArgs? = nil, or: [RoleWhereArgs?]? = nil, and: [RoleWhereArgs?]? = nil) {
    graphQLMap = ["members": members, "createdAt": createdAt, "modifiedAt": modifiedAt, "id": id, "name": name, "OR": or, "AND": and]
  }
}

/// Select objects by filtering on objects in a connection
public struct RoleMembersWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(edge: UserRolesEdgeWhereArgs? = nil, node: UserWhereArgs? = nil) {
    graphQLMap = ["edge": edge, "node": node]
  }
}

public struct RoleCreatedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct RoleModifiedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct RoleIdWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: GraphQLID? = nil, ne: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "in": `in`, "notIn": notIn, "isNull": isNull]
  }
}

public struct RoleNameWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct UserLastLoginWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct UserIdWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: GraphQLID? = nil, ne: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "in": `in`, "notIn": notIn, "isNull": isNull]
  }
}

public struct UserPasswordWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct UserUsernameWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct UserCreatedAtWhereArgs: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: String? = nil, ne: String? = nil, gt: String? = nil, gte: String? = nil, lt: String? = nil, lte: String? = nil, between: [String?]? = nil, notBetween: [String?]? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil, like: String? = nil, notLike: String? = nil, isNull: Bool? = nil) {
    graphQLMap = ["eq": eq, "ne": ne, "gt": gt, "gte": gte, "lt": lt, "lte": lte, "between": between, "notBetween": notBetween, "in": `in`, "notIn": notIn, "like": like, "notLike": notLike, "isNull": isNull]
  }
}

public struct LoginUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(username: String, password: String, clientMutationId: String? = nil) {
    graphQLMap = ["username": username, "password": password, "clientMutationId": clientMutationId]
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

public final class CreateTripMutation: GraphQLMutation {
  public static let operationDefinition =
    "mutation CreateTrip($trip: CreateTripInput!) {" +
    "  createTrip(input: $trip) {" +
    "    __typename" +
    "    clientMutationId" +
    "    changedTrip {" +
    "      __typename" +
    "      id" +
    "    }" +
    "  }" +
    "}"

  public let trip: CreateTripInput

  public init(trip: CreateTripInput) {
    self.trip = trip
  }

  public var variables: GraphQLMap? {
    return ["trip": trip]
  }

  public struct Data: GraphQLMappable {
    /// Create objects of type Trip.
    public let createTrip: CreateTrip?

    public init(reader: GraphQLResultReader) throws {
      createTrip = try reader.optionalValue(for: Field(responseName: "createTrip", arguments: ["input": reader.variables["trip"]]))
    }

    public struct CreateTrip: GraphQLMappable {
      public let __typename: String
      /// An opaque string used by frontend frameworks like relay to track requests and responses.
      public let clientMutationId: String?
      /// The mutated Trip.
      public let changedTrip: ChangedTrip?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        clientMutationId = try reader.optionalValue(for: Field(responseName: "clientMutationId"))
        changedTrip = try reader.optionalValue(for: Field(responseName: "changedTrip"))
      }

      public struct ChangedTrip: GraphQLMappable {
        public let __typename: String
        /// A globally unique ID.
        public let id: GraphQLID

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.value(for: Field(responseName: "id"))
        }
      }
    }
  }
}

public final class GetAllUsersQuery: GraphQLQuery {
  public static let operationDefinition =
    "query GetAllUsers($where: UserWhereArgs) {" +
    "  viewer {" +
    "    __typename" +
    "    allUsers(where: $where) {" +
    "      __typename" +
    "      edges {" +
    "        __typename" +
    "        node {" +
    "          __typename" +
    "          username" +
    "        }" +
    "      }" +
    "    }" +
    "  }" +
    "}"

  public let `where`: UserWhereArgs?

  public init(`where`: UserWhereArgs? = nil) {
    self.`where` = `where`
  }

  public var variables: GraphQLMap? {
    return ["where": `where`]
  }

  public struct Data: GraphQLMappable {
    public let viewer: Viewer?

    public init(reader: GraphQLResultReader) throws {
      viewer = try reader.optionalValue(for: Field(responseName: "viewer"))
    }

    public struct Viewer: GraphQLMappable {
      public let __typename: String
      /// Sift through all objects of type 'User'.
      public let allUsers: AllUser?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        allUsers = try reader.optionalValue(for: Field(responseName: "allUsers", arguments: ["where": reader.variables["where"]]))
      }

      public struct AllUser: GraphQLMappable {
        public let __typename: String
        /// The set of edges in this page.
        public let edges: [Edge?]?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          edges = try reader.optionalList(for: Field(responseName: "edges"))
        }

        public struct Edge: GraphQLMappable {
          public let __typename: String
          /// The node value for the edge.
          public let node: Node

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            node = try reader.value(for: Field(responseName: "node"))
          }

          public struct Node: GraphQLMappable {
            public let __typename: String
            /// The user's username.
            public let username: String

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              username = try reader.value(for: Field(responseName: "username"))
            }
          }
        }
      }
    }
  }
}

public final class GetTripMessagesQuery: GraphQLQuery {
  public static let operationDefinition =
    "query GetTripMessages($id: ID!) {" +
    "  getTrip(id: $id) {" +
    "    __typename" +
    "    messages {" +
    "      __typename" +
    "      edges {" +
    "        __typename" +
    "        node {" +
    "          __typename" +
    "          author {" +
    "            __typename" +
    "            id" +
    "            username" +
    "          }" +
    "          contentString" +
    "        }" +
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
      /// The reverse field of 'trip' in 1:M connection
      /// with type 'undefined'.
      public let messages: Message?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        messages = try reader.optionalValue(for: Field(responseName: "messages"))
      }

      public struct Message: GraphQLMappable {
        public let __typename: String
        /// The set of edges in this page.
        public let edges: [Edge?]?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          edges = try reader.optionalList(for: Field(responseName: "edges"))
        }

        public struct Edge: GraphQLMappable {
          public let __typename: String
          /// The node value for the edge.
          public let node: Node

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            node = try reader.value(for: Field(responseName: "node"))
          }

          public struct Node: GraphQLMappable {
            public let __typename: String
            public let author: Author?
            public let contentString: String

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              author = try reader.optionalValue(for: Field(responseName: "author"))
              contentString = try reader.value(for: Field(responseName: "contentString"))
            }

            public struct Author: GraphQLMappable {
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
}

public final class GetTripNameQuery: GraphQLQuery {
  public static let operationDefinition =
    "query GetTripName($id: ID!) {" +
    "  getTrip(id: $id) {" +
    "    __typename" +
    "    tripName" +
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
      public let tripName: String

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        tripName = try reader.value(for: Field(responseName: "tripName"))
      }
    }
  }
}

public final class GetUserIdQuery: GraphQLQuery {
  public static let operationDefinition =
    "query GetUserID {" +
    "  viewer {" +
    "    __typename" +
    "    user {" +
    "      __typename" +
    "      id" +
    "    }" +
    "  }" +
    "}"
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let viewer: Viewer?

    public init(reader: GraphQLResultReader) throws {
      viewer = try reader.optionalValue(for: Field(responseName: "viewer"))
    }

    public struct Viewer: GraphQLMappable {
      public let __typename: String
      /// Returns the currently logged in user and is also the entry point for queries that leverage RELATION scoped permissions.
      public let user: User?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        user = try reader.optionalValue(for: Field(responseName: "user"))
      }

      public struct User: GraphQLMappable {
        public let __typename: String
        /// A globally unique ID.
        public let id: GraphQLID

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.value(for: Field(responseName: "id"))
        }
      }
    }
  }
}

public final class LoginUserMutation: GraphQLMutation {
  public static let operationDefinition =
    "mutation LoginUser($user: LoginUserInput!) {" +
    "  loginUser(input: $user) {" +
    "    __typename" +
    "    token" +
    "  }" +
    "}"

  public let user: LoginUserInput

  public init(user: LoginUserInput) {
    self.user = user
  }

  public var variables: GraphQLMap? {
    return ["user": user]
  }

  public struct Data: GraphQLMappable {
    public let loginUser: LoginUser?

    public init(reader: GraphQLResultReader) throws {
      loginUser = try reader.optionalValue(for: Field(responseName: "loginUser", arguments: ["input": reader.variables["user"]]))
    }

    public struct LoginUser: GraphQLMappable {
      public let __typename: String
      /// The user's authentication token. Embed this under the
      /// 'Authorization' header with the format 'Bearer <token>'
      /// 
      public let token: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        token = try reader.optionalValue(for: Field(responseName: "token"))
      }
    }
  }
}