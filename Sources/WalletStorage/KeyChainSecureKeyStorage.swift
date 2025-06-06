//
//  ks.swift
//  WalletStorage
//
//  Created by ffeli on 25/10/2024.
//

import Foundation
import MdocDataModel18013

public actor KeyChainSecureKeyStorage: SecureKeyStorage {
	public let serviceName: String
	public let accessGroup: String?
	var dict: [String: Data]?
	var keyOptions: KeyOptions?
	
	public init(serviceName: String, accessGroup: String?) {
		self.serviceName = serviceName
		self.accessGroup = accessGroup
	}
	
	static func keyChainDataValue(key: String, value: Any) -> (String, Data)? {
		if let v = value as? String { (key, v.data(using: .utf8)!) } else if let v = value as? Data { (key, v) } else { nil }
	}
	
	public func readKeyInfo(id: String) throws -> [String : Data] {
		guard let dicts = try KeyChainStorageService.loadData(serviceName: serviceName, accessGroup: accessGroup, id: id, status: .issued, dataToLoadType: .keyInfo), !dicts.isEmpty else { return [:] }
		return Dictionary(uniqueKeysWithValues: dicts.first!.compactMap(Self.keyChainDataValue))
	}
	
	public func readKeyData(id: String, index: Int) throws -> [String : Data] {
		guard let dicts = try KeyChainStorageService.loadData(serviceName: serviceName, accessGroup: accessGroup, id: "\(id)_\(index)", status: .issued, dataToLoadType: .key), !dicts.isEmpty else { return [:] }
		return Dictionary(uniqueKeysWithValues: dicts.first!.compactMap(Self.keyChainDataValue))
	}
	
	// save key public info
	public func writeKeyInfo(id: String, dict: [String: Data]) throws {
		self.dict = dict
		try KeyChainStorageService.saveDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: id, status: .issued, dataType: .keyInfo, setDictValues: setDictValues1, allowOverwrite: true)
	}
	
	// save key batch info
	public func writeKeyDataBatch(id: String, startIndex: Int, dicts: [[String : Data]], keyOptions: MdocDataModel18013.KeyOptions?) async throws {
		guard dicts.count > 0 else { return }
		self.keyOptions = keyOptions
		for i in startIndex..<dicts.count+startIndex {
			self.dict = dicts[i]
			try KeyChainStorageService.saveDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: "\(id)_\(i)", status: .issued, dataType: .key, setDictValues: setDictValues2, allowOverwrite: true)
		}
	}
	
	// delete key info and data
	public func deleteKeyBatch(id: String, batchSize: Int) throws {
		logger.info("Delete key-batch with id \(id)")
		for index in 0..<batchSize {
			try? KeyChainStorageService.deleteDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: "\(id)_\(index)", docStatus: .issued, dataType: .key)
		}
		try KeyChainStorageService.deleteDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: id, docStatus: .issued, dataType: .keyInfo)
	}
	
	// helper function to convert generic data dictionary to keychain expected dictionary
	func setDictValues1(_ d: inout [String: Any]) {
		guard let dict else { return }
		for (k, v) in dict { d[k] = if k == kSecValueData as String { v } else { String(data: v, encoding: .utf8) ?? "" } }
	}
	
	// helper function to convert generic data dictionary to keychain expected dictionary, create access control value if needed
	func setDictValues2(_ d: inout [String: Any]) {
		guard let dict else { return }
		for (k, v) in dict { d[k] = if k == kSecValueData as String { v } else { String(data: v, encoding: .utf8) ?? "" } }
		d[kSecAttrAccessControl as String] = SecAccessControlCreateWithFlags(nil, keyOptions?.accessProtection?.constant ?? kSecAttrAccessibleWhenUnlocked, keyOptions?.accessControl?.flags ?? [], nil)! as Any
	}

}

