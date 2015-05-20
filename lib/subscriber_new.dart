part of redis;

class PubSub{
  Command _command;
  StreamController _stream_controler = new StreamController();
  Future _forever;
  
  PubSub(Command command){
    _command=new  Command(command._connection);
    _forever = command.send_nothing().then((_){
      //override socket with warrning
      command._connection = new _WarrningPubSubInProgress(); 
      // listen and process forever
      return Future.doWhile((){
          return _command._connection._senddummy()
          .then((var data){
              _stream_controler.add(data);
               return true;
          });
      });
    });
  }
  
  
  Stream getStream(){
    return _stream_controler.stream;
  }
  
  void subscribe(List<String> s){
    _sendcmd_and_list("SUBSCRIBE",s);
  }
  
  void  psubscribe(List<String> s){
    _sendcmd_and_list("PSUBSCRIBE",s);
  }
  
  void unsubscribe(List<String> s){
    _sendcmd_and_list("UNSUBSCRIBE",s);
  }

  void punsubscribe(List<String> s){
    _sendcmd_and_list("PUNSUBSCRIBE",s);
  }
  
  void _sendcmd_and_list(String cmd,List<String> s){
    List list = [cmd];
    list.addAll(s);
    _command._connection._socket.add(RedisSerialise.Serialise(list));
  }
} 