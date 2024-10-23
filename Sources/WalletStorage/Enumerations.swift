/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation

/// type of data to save in storage
/// ``doc``: Document data
/// ``key``: Private-key
public enum SavedKeyChainDataType: String, Sendable {
	case doc = "sdoc"
	case key = "skey"
	case keyInfo = "skei"
}

/// Format of document data
/// ``cbor``: DeviceResponse cbor encoded
/// ``sjwt``: sd-jwt ** not yet supported **
/// ``signupResponseJson``: DeviceResponse and PrivateKey json serialized
/// ``deferred``: Deferred issuance data
public enum DocDataType: String, Sendable {
	case cbor = "cbor"
	case sjwt = "sjwt"
	case signupResponseJson = "srjs"
}

/// Format of private key
/// ``x963EncodedP256``: ANSI x9.63 representation (default)
/// ``secureEnclaveP256``: data representation for the secure enclave
public enum PrivateKeyType: String, Sendable {
	case x963EncodedP256 = "p256"
	case secureEnclaveP256 = "sep2"
}


/// document status
public enum DocumentStatus: String, CaseIterable, Sendable {
	case issued
	case deferred
	case pending
}
