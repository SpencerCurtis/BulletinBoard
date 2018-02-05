//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Andrew Madsen on 6/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

private let CreatorUserRecordIDKey = "creatorUserRecordID"
private let LastModifiedUserRecordIDKey = "creatorUserRecordID"
private let CreationDateKey = "creationDate"
private let ModificationDateKey = "modificationDate"

class CloudKitManager {
    
	let database = CKContainer.default().publicCloudDatabase
	
	func fetchRecords(ofType type: String,
	                          sortDescriptors: [NSSortDescriptor]? = nil,
	                          completion: @escaping ([CKRecord]?, Error?) -> Void) {
		
		let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
		query.sortDescriptors = sortDescriptors
		
		database.perform(query, inZoneWith: nil, completionHandler: completion)
	}
	
	func save(_ record: CKRecord, completion: @escaping ((Error?) -> Void) = { _ in }) {
		
		database.save(record, completionHandler: { (record, error) in
			completion(error)
		}) 
	}
	
	func subscribeToCreationOfRecords(ofType type: String, completion: @escaping ((Error?) -> Void) = { _ in }) {
		let subscription = CKQuerySubscription(recordType: type, predicate: NSPredicate(value: true), options: .firesOnRecordCreation)

		let notificationInfo = CKNotificationInfo()
		notificationInfo.alertBody = "There's a new message on the bulletin board."
		subscription.notificationInfo = notificationInfo
		database.save(subscription, completionHandler: { (subscription, error) in
			if let error = error {
				NSLog("Error saving subscription: \(error)")
			}
			completion(error)
		}) 
	}
    
    // MARK: - User Discoverability
    
    func requestDiscoverabilityAuthorization(completion: @escaping (CKApplicationPermissionStatus, Error?) -> Void) {
        
        CKContainer.default().status(forApplicationPermission: .userDiscoverability) { (permissionStatus, error) in
            
            guard permissionStatus != .granted else { completion(.granted, error); return }
            
            CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: completion)
        }
    }
    
    func fetchUserIdentityWith(email: String, completion: @escaping (CKUserIdentity?, Error?) -> Void) {
        
        CKContainer.default().discoverUserIdentity(withEmailAddress: email, completionHandler: completion)
    }
    
    func fetchAllDiscoverableUserIdentities(completion: @escaping ([CKUserIdentity], Error?) -> Void) {
        
        let discoverIdentitiesOp = CKDiscoverAllUserIdentitiesOperation()
        
        var discoveredIdentities: [CKUserIdentity] = []
        
        discoverIdentitiesOp.userIdentityDiscoveredBlock = { identity in
            
            discoveredIdentities.append(identity)
        }
        
        discoverIdentitiesOp.discoverAllUserIdentitiesCompletionBlock = { error in
            
            completion(discoveredIdentities, error)
        }
        
        CKContainer.default().add(discoverIdentitiesOp)
    }
    
}
