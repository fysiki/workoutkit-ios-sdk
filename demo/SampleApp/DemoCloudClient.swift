//
//  DemoCloudClient.swift
//  SampleApp
//


// MARK: - Cloud client

import Apollo
import ApolloAPI
import ApolloSQLite
import DemoCloud
import Foundation
import FZWorkoutKit

enum DemoCloudClient {
    static var shared: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 10

        let client = URLSessionClient(sessionConfiguration: configuration)
        let cache: NormalizedCache

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let sqliteFileURL = documentsURL.appendingPathComponent("test_apollo_db.sqlite")
        if let sqliteCache = try? SQLiteNormalizedCache(fileURL: sqliteFileURL) {
            cache = sqliteCache
        } else {
            cache = InMemoryNormalizedCache()
        }

        let store = ApolloStore(cache: cache)

        var url = URL(string: "https://server.com/graphql")!
        let useAPQ = true
        let provider = DemoNetworkInterceptorProvider(store: store)

        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url, autoPersistQueries: useAPQ)
        let apollo = ApolloClient(networkTransport: transport, store: store)
        return apollo
    }()
}

// MARK: - Interceptors

class DemoNetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors(for operation: some GraphQLOperation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)

        // Add headers.
        interceptors.insert(DemoHeadersAddingInterceptor(), at: 0)

        return interceptors
    }
}

class DemoHeadersAddingInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        request.addHeader(name: "X-WorkoutKit-Device", value: WorkoutKitConfig.deviceId())
        chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
    }
}
