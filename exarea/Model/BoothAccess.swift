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
    let recipientName: String?
    let conversationStatus: String
    let senderArchive: Bool
    let modifiedDate: String
}

struct Mail: JSONSerializable {
    let mailguid: String
    let userName: String
    let conversationID: String
    let title: String
    let senderID: Int
    let modifiedDate: String
    let readDateTime: String?
    let replyTo: String?
    let content: String
}

extension Conversation {
    static func getAllBoothAccesses(completion: @escaping DataResult<[BoothAccess]>) {
        let params = ["OnTicket": "True", "IsActive": "True"]
        let req = CustomRequest(path: "/Conversation/BoothAccessList", method: .post, parameters: params).api().authorize()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: [BoothAccess].responseDataSerializer) { response in
                completion(response.result)
        }
    }
    
    static func begin(with form: TicketForm, completion: @escaping DataResult<String>) {
        
        let req = CustomRequest(path: "/Conversation/StartConversation", method: .post, parameters: form.parameters!).api().authorize()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: String.responseDataSerializer) { response in
                completion(response.result)
        }
    }
    
    static func sentByUser(completion: @escaping DataResult<[Conversation]>) {
        let req = CustomRequest(path: "/Conversation/SentByPerson", method: .post, parameters: ["Archive": false]).api().authorize()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: [Conversation].responseDataSerializer) { response in
                completion(response.result)
        }
    }
    
    func getMails(completion: @escaping DataResult<[Mail]>) {
        let params = ["ConversationID": self.conversationID]
        let req = CustomRequest(path: "/Conversation/ConversationMails", method: .post, parameters: params).api().authorize()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: [Mail].responseDataSerializer) { response in
                completion(response.result)
        }
    }

    func resume(content: String, replyingTo mail: Mail? = nil, completion: @escaping ErrorableResult) {
        var params = [
        "ConversationID": self.conversationID,
        "Content": content
        ]
        
        if let replyID = mail?.mailguid {
            params["ReplyTo"] = replyID
        }
        
        let req = CustomRequest(path: "/Conversation/ResumeConversation", method: .post, parameters: params).api().authorize()
        
        NetworkManager.session
            .requestWithValidation(req)
            .responseData() { response in
                completion(response.result.error)
        }
    }
}
