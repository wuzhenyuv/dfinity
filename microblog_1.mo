import Time = "mo:base/Time";
import List = "mo:base/List";
import Iter = "mo:base/Iter";
import Principal = "mo:base/Principal";

actor{
    public type Message = {
        msg : Text; 
        time : Nat64;};

    public type Microblog = actor{
        follow : shared(Principal) -> async();
        follows : shared query() -> async[Principal];
        post : shared(Text) -> async();
        posts : shared query() -> async[Message];
        timeline : shared query() -> async[Message];
    };

    var followed : List.List<Principal> = List.nil();

    public shared func follow(id : Principal) : async(){
        followed := List.push(id,followed);
    };

    public shared query func follows() : async[Principal]{
        List.toArray(followed)
    };

    var messages : List.List<Message> = List.nil();

    public shared func post(msg : Message) : async(){
        messages := List.push(msg,messages);
    };

    public shared query func posts() : async[Message]{
        List.toArray(messages)
    };

    public shared func timeline() : async[Message]{
        var all : List.List<Message> = List.nil();

        for(id in Iter.fromList(followed)){
            let canister : Microblog = actor(Principal.toText(id)); 
            let msgs = await canister.posts();
            for(msg in Iter.fromArray(msgs)){
                all := List.push(msg,all);
            }
        };
        List.toArray(all)
    };
}  
