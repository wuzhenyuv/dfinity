import Time = "mo:base/Time";
import List = "mo:base/List";
import Iter = "mo:base/Iter";
import Principal = "mo:base/Principal";

actor{
    public type Message = {
        content : Text; 
        time : Int;
        author : Text;
        };

    public type Microblog = actor{
        follow : shared(Text,Principal) -> async();
        follows : shared query() -> async[Principal];
        post : shared(Text,Text) -> async();
        posts : shared query(Time.Time) -> async[Message];
        timeline : shared (Time.Time) -> async[Message];
        get_name : shared query () -> async (?Text);
        set_name : shared(Text,Text) -> async();

    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(otp:Text,id : Principal) : async(){
        assert(otp == "139515");
        followed := List.push(id,followed);
    };

    public shared query func follows() : async[Principal]{
        List.toArray(followed)
    };

    stable var messages : List.List<Message> = List.nil();
    stable var author : Text = "Wayne";

    public shared func set_name(otp:Text,name:Text) : async(){
        assert(otp == "139515");
        author := name;
    };

    public shared query func get_name() : async (?Text){
        ?author
    };

    public shared(msg) func post(otp:Text,text : Text) : async(){
        assert(otp == "123456");
        let message : Message = {
            content = text;
            time = Time.now();
            author = author;
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

    public shared func get_other_name(id:Principal) : async (?Text){
       let canister : Microblog = actor(Principal.toText(id)); 
       let name = await canister.get_name();
       name
    };

    public shared func get_other_posts(id:Principal) : async([Message]){
       let canister : Microblog = actor(Principal.toText(id)); 
       let otherPosts:[Message] = await canister.posts(1);
       otherPosts
    };
} 
