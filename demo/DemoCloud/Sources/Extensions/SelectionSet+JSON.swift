//
//  SelectionSet+JSON.swift
//  DemoCloud
//
//  Created by Benoit Deldicque on 09/01/2026.
//

@_spi(Unsafe) import ApolloAPI
@_spi(Internal) import ApolloAPI
import Foundation

/// Extension to convert Apollo GraphQL `SelectionSet` objects to JSON data.
///
/// This extension provides functionality to serialize Apollo SelectionSet types
/// into JSON `Data`, making it easier to pass GraphQL query results to components
/// that require JSON representation.
public extension SelectionSet {
    /// Converts the selection set to JSON data.
    ///
    /// This method serializes the internal data structure of the SelectionSet
    /// into a JSON representation, handling nested objects, arrays, and custom
    /// scalar types appropriately.
    ///
    /// - Returns: A `Data` object containing the JSON representation of the selection set.
    /// - Throws: An error if the JSON serialization fails.
    func asJSONData() throws -> Data {
        try JSONSerialization.data(withJSONObject: convert(value: __data))
    }

    /// Recursively converts Apollo internal types to JSON-compatible types.
    ///
    /// This method traverses the data structure and converts Apollo-specific types
    /// (like `DataDict` and `CustomScalarType`) into standard Swift types that can
    /// be serialized to JSON.
    ///
    /// - Parameter value: The value to convert. Can be a `DataDict`, dictionary, array,
    ///   custom scalar, or any other JSON-compatible type.
    /// - Returns: A JSON-compatible representation of the input value.
    private func convert(value: Any) -> Any {
        if let value = value as? ApolloAPI.DataDict {
            return convert(value: value._data)
        } else if let value = value as? [String: Any] {
            return value.mapValues(convert)
        } else if let value = value as? [Any] {
            return value.map(convert)
        } else if let value = value as? (any CustomScalarType) {
            return value._jsonValue
        }
        return value
    }
}
