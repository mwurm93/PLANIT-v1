/* File: addGraphQLSubscriptions.js */

import { print } from 'graphql-tag/printer';

// quick way to add the subscribe and unsubscribe functions to the network interface
export default function addGraphQLSubscriptions(networkInterface, wsClient) {
    return Object.assign(networkInterface, {
                         subscribe(request, handler) {
                         return wsClient.subscribe({
                                                   query: print(request.query),
                                                   variables: request.variables,
                                                   }, handler);
                         },
                         unsubscribe(id) {
                         wsClient.unsubscribe(id);
                         },
                         });
}

/* End of file: addGraphQLSubscriptions.js */

------------------------------------------------------------------------

/* File: makeApolloClient.js */

import addGraphQLSubscriptions from './addGraphQLSubscriptions';
import ApolloClient, { createNetworkInterface } from 'apollo-client';
import { Client } from 'subscriptions-transport-ws';

// creates a subscription ready Apollo Client instance
export function makeApolloClient() {
    const scapholdUrl = 'us-west-2.api.scaphold.io/graphql/scaphold-graphql';
    const graphqlUrl = `https://${scapholdUrl}`;
    const websocketUrl = `wss://${scapholdUrl}`;
    const networkInterface = createNetworkInterface(graphqlUrl);
    networkInterface.use([{
                          applyMiddleware(req, next) {
                          // Easy way to add authorization headers for every request
                          if (!req.options.headers) {
                          req.options.headers = {};  // Create the header object if needed.
                          }
                          if (localStorage.getItem('scaphold_user_token')) {
                          // This is how to authorize users using http auth headers
                          req.options.headers.Authorization = `Bearer ${localStorage.getItem('scaphold_user_token')}`;
                          }
                          next();
                          },
                          }]);
    const wsClient = new Client(websocketUrl);
    const networkInterfaceWithSubscriptions = addGraphQLSubscriptions(networkInterface, wsClient);
    
    const clientGraphql = new ApolloClient({
                                           networkInterface: networkInterfaceWithSubscriptions,
                                           initialState: {},
                                           });
    return clientGraphql;
}

/* End of File: makeApolloClient.js */
