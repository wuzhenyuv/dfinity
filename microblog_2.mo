import Time = "mo:base/Time";
import List = "mo:base/List";
import Iter = "mo:base/Iter";
import Principal = "mo:base/Principal";

actor{
    public type Message = {
        msg : Text; 
        time : Int;
        };

    public type Microblog = actor{
        follow : shared(Principal) -> async();
        follows : shared query() -> async[Principal];
        post : shared(Text) -> async();
        posts : shared query(Time.Time) -> async[Message];
        timeline : shared (Time.Time) -> async[Message];
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id : Principal) : async(){
        followed := List.push(id,followed);
    };

    public shared query func follows() : async[Principal]{
        List.toArray(followed)
    };

    stable var messages : List.List<Message> = List.nil();

    public shared(msg) func post(text : Text) : async(){
        assert(Principal.toText(msg.caller) == "jnbyw-lw2cj-y2pgw-vtdr4-cenwj-zvfei-yo4ru-pbx3c-mkteo-phhzz-hqe");
        let message : Message = {
            msg = text;
            time = Time.now();
        };
        messages := List.push(message,messages);
    };

    public shared query func posts(since : Time.Time) : async[Message]{
        var messages_since_time : List.List<Message> = List.nil();
        for(msg in Iter.fromList(messages)){
            if(msg.time >= since){
               messages_since_time := List.push(msg,messages_since_time);
            }
        };
        List.toArray(messages_since_time)
    };

    public shared func timeline(since : Time.Time) : async[Message]{
        var all : List.List<Message> = List.nil();
        for(id in Iter.fromList(followed)){
            let canister : Microblog = actor(Principal.toText(id)); 
            let msgs = await canister.posts(since);
            for(msg in Iter.fromArray(msgs)){
                all := List.push(msg,all);
            }
        };
        List.toArray(all)
    };
} 
