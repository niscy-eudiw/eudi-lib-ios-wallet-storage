//
//  ks.swift
//  WalletStorage
//
//  Created by ffeli on 25/10/2024.
//

import Foundation
import MdocDataModel18013

public class KeyChainSecureKeyStorage: SecureKeyStorage, @unchecked Sendable {
	public let serviceName: String
	public let accessGroup: String?
	
	public init(serviceName: String, accessGroup: String?) {
		self.serviceName = serviceName
		self.accessGroup = accessGroup
	}
	
	static func keyChainDataValue(key: String, value: Any) -> (String, Data)? {
		if let v = value as? String { (key, v.data(using: .utf8)!) } else if let v = value as? Data { (key, v) } else { nil }
	}
	
	public func readKeyInfo(id: String) throws -> [String : Data] {
		guard let dicts = try KeyChainStorageService.loadDocumentsData(serviceName: serviceName, accessGroup: accessGroup, id: id, status: .issued, dataToLoadType: .keyInfo), !dicts.isEmpty else { return [:] }
		return Dictionary(uniqueKeysWithValues: dicts.first!.compactMap(Self.keyChainDataValue))
	}
	
	public func readKeyData(id: String) throws -> [String : Data] {
		guard let dicts = try KeyChainStorageService.loadDocumentsData(serviceName: serviceName, accessGroup: accessGroup, id: id, status: .issued, dataToLoadType: .key), !dicts.isEmpty else { return [:] }
		return Dictionary(uniqueKeysWithValues: dicts.first!.compactMap(Self.keyChainDataValue))
	}
	
	// save key public info
	public func writeKeyInfo(id: String, dict: [String: Data]) throws {
		func setDictValues(_ d: inout [String: Any]) { for (k, v) in dict { d[k] = if k == kSecValueData as String { v } else { String(data: v, encoding: .utf8) ?? "" } } }
		try KeyChainStorageService.saveDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: id, status: .issued, dataType: .keyInfo, setDictValues: setDictValues, allowOverwrite: true)
	}
	
	// save key sensitive info
	public func writeKeyData(id: String, dict: [String: Data], keyOptions: KeyOptions?) throws {
		func setDictValues(_ d: inout [String: Any]) {
			for (k, v) in dict { d[k] = if k == kSecValueData as String { v } else { String(data: v, encoding: .utf8) ?? "" } }
			d[kSecAttrAccessControl as String] = SecAccessControlCreateWithFlags(nil, keyOptions?.accessProtection?.constant ?? kSecAttrAccessibleWhenUnlockedThisDeviceOnly, keyOptions?.accessControl?.flags ?? [], nil)! as Any
		}
		try KeyChainStorageService.saveDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: id, status: .issued, dataType: .key, setDictValues: setDictValues, allowOverwrite: true)
	}
	
	// delete key info and data
	public func deleteKey(id: String) throws {
		logger.info("Delete key with id \(id)")
		try? KeyChainStorageService.deleteDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: id, docStatus: .issued, dataType: .keyInfo)
		try KeyChainStorageService.deleteDocumentData(serviceName: serviceName, accessGroup: accessGroup, id: id, docStatus: .issued, dataType: .key)
	}
	
}
