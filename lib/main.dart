import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   final client = StreamChatClient(
     // add your Api key from stream chat id
     'm7kca6r6q6gx',
     logLevel: Level.INFO,
  );
   await client.connectUser(
     User(id: 'flutter-tutorial'),
     // to generate user token use https://getstream.io/chat/docs/flutter-dart/tokens_and_authentication/?language=ruby
     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY2hhdF91c2VyIn0.50KHpoYo2B6R7PCRW8_Kqdv30SafSx68lqRFGkJU5AM",
   );
   final channel = client.channel('messaging',
       // user id on which user token generate
       id: 'chat_user');
  channel.watch();
  runApp( MyApp(client: client,channel: channel,));

}

class MyApp extends StatelessWidget {
  final StreamChatClient client;
  final Channel channel;
  const MyApp(
      {super.key, required this.client, required this.channel});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      builder: (context,child){
        return StreamChat(
          client: client,
          child: child,
        );
      },
      home:  StreamChannel(
            channel: channel,
            child: ChannelListPage(),
      )
    );
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: StreamChannelHeader(),
        body: Column(
          children: [
            Expanded(child: StreamMessageListView(),),
            StreamMessageInput()
          ],
        ),
      ),
    );
  }
}
class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late final _listController = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    sort: const [SortOption('last_message_at')],
    limit: 20,
  );

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamChannelListView(
        controller: _listController,
        onChannelTap: (channel) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return StreamChannel(
                  channel: channel,
                  child: const ChannelPage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

