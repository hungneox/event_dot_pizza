import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/settings_page.dart';
import '../widgets/event_list_item.dart';
import '../widgets/no_events_overlay.dart';
import '../providers/events.dart';

class EventsPage extends StatefulWidget {
  static const routeName = "events";
  @override
  _EventsPageState createState() => _EventsPageState();
}

const List<BottomNavigationBarItem> bottomNavigationBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.watch_later),
    title: Text('Anytime'),
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.calendar_today),
    title: Text('Today'),
  ),
];

const noEventsOverlayMessages = [
  'No free pizza for you anytime soon!',
  'No free pizza for you today!'
];

class _EventsPageState extends State<EventsPage> with WidgetsBindingObserver {
  final _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterInitState());
    super.initState();
  }

  void _afterInitState() {
    refreshIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild());
    final eventsProvider = Provider.of<Events>(context);
    final eventLists = [eventsProvider.events, eventsProvider.todayEvents];
    final numberOfEvents = eventLists[_selectedTabIndex].length;
    final bool shouldShowNoEventsOverlay =
        !eventsProvider.needsRefresh && numberOfEvents == 0;
    final EdgeInsets safePadding = MediaQuery.of(context).padding;
    final listEdgeInsets = EdgeInsets.fromLTRB(0, 10.0, 0, safePadding.bottom);
    return Scaffold(
      appBar: AppBar(
        title: Text('Event.Pizza 🍕'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(
              context,
              SettingsPage.routeName,
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async => eventsProvider.refreshEvents(),
        child: Stack(
          children: <Widget>[
            Visibility(
              visible: shouldShowNoEventsOverlay,
              child: NoEventsOverlay(
                message: noEventsOverlayMessages[_selectedTabIndex],
              ),
            ),
            IndexedStack(
              index: _selectedTabIndex,
              sizing: StackFit.expand,
              children: eventLists
                  .map(
                    (eventList) => Scrollbar(
                      child: ListView.separated(
                        padding: listEdgeInsets,
                        itemCount: eventList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) =>
                            EventListItem(event: eventList[index]),
                      ),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavigationBarItems,
        currentIndex: _selectedTabIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: (index) => setState(() => _selectedTabIndex = index),
      ),
    );
  }

  void _afterBuild() {
    refreshIfNeeded();
  }

  void refreshIfNeeded() {
    if (Provider.of<Events>(context).needsRefresh) {
      _refreshIndicatorKey?.currentState?.show();
    }
  }
}
