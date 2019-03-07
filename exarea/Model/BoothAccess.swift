//
//  BoothAccess.swift
//  
//
//  Created by Soroush on 12/16/1397 AP.
//

import Alamofire

struct TicketForm: JSONSerializable {
    let boothAccessID: Int
    let title: String
    let content: String
}

struct BoothAccess: JSONSerializable {
    let boothAccessID: Int
    let boothAccessName: String
    let onTicket: Bool
    let isActive: Bool
    let modifiedDate: String
}

struct Conversation: JSONSerializable {
    let conversationID: String
    let title: String
    let senderID: Int
    let recipientName: String
    let conversationStatus: String
    let senderArchive: Bool
    let modifiedDate: String
}

extension Conversation {
    static func getAllBoothAccesses(completion: @escaping DataResult<[BoothAccess]>) {
        let params = ["OnTicket": "True", "IsActive": "True"]
        let req = CustomRequest(path: "/Conversation/BoothAccessList", method: .post, parameters: params).api().authorize()
        NetManager
            .shared
            .requestWithValidation(req)
            .response(responseSerializer: [BoothAccess].responseDataSerializer) { response in
                completion(response.result)
        }
    }
    
    static func begin(with form: TicketForm, completion: @escaping DataResult<String>) {
        
        let req = CustomRequest(path: "/Conversation/StartConversation", method: .post, parameters: form.parameters!).api().authorize()
        NetManager
            .shared
            .requestWithValidation(req)
            .response(responseSerializer: String.responseDataSerializer) { response in
                completion(response.result)
        }
    }

}
