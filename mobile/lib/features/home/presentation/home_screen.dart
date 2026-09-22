import 'package:joicrememory/l10n/localization.dart';
import '../../map/presentation/widgets/map_filters_sheet.dart';
import '../../../core/ui/loading_skeleton.dart';
import '../../../core/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import '../../../app/app_scope.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../events/domain/entities/event.dart';
import '../../events/domain/entities/event_location.dart';
import '../../events/presentation/event_category.dart';
import '../../events/presentation/event_details_screen.dart';
import '../domain/entities/discovery_area.dart';
import '../domain/usecases/discover_events.dart';
import 'controllers/home_controller.dart';
import '../../events/presentation/widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.session,
    required this.onCreate,
    required this.onMap,
    required this.onProfile,
    required this.refreshSignal,
  });
  final AuthController session;
  final VoidCallback onCreate;
  final VoidCallback onMap;
  final VoidCallback onProfile;
  final int refreshSignal;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  final _search = TextEditingController();
  static const _cities = [
    DiscoveryArea('Львів', EventLocation(49.8397, 24.0297)),
    DiscoveryArea('Київ', EventLocation(50.4501, 30.5234)),
    DiscoveryArea('Івано-Франківськ', EventLocation(48.9226, 24.7111)),
    DiscoveryArea('Тернопіль', EventLocation(49.5535, 25.5948)),
    DiscoveryArea('Одеса', EventLocation(46.4825, 30.7233)),
    DiscoveryArea('Дніпро', EventLocation(48.4647, 35.0462)),
    DiscoveryArea('Харків', EventLocation(49.9935, 36.2304)),
  ];

  @override
  void initState() {
    super.initState();
    final scope = AppScope.read(context);
    _controller = HomeController(
      DiscoverEvents(scope.events, scope.location),
      scope.events,
    );
    _controller.refresh();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) _controller.refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _openEvent(Event event) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => EventDetailsScreen(session: widget.session, event: event),
      ),
    );
    if (mounted) await _controller.refresh();
  }

  Future<void> _chooseArea() async {
    // Null means dismiss; -1 explicitly selects device location.
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.whereShouldWeLook,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      context.l10n.showingEventsWithinTheSelectedSearchRadius,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.my_location),
                      title: Text(context.l10n.nearMe),
                      subtitle: Text(context.l10n.usingYourDeviceSLocation),
                      onTap: () => Navigator.pop(context, -1),
                    ),
                    Divider(),
                    for (var i = 0; i < _cities.length; i++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_cities[i].name),
                        trailing:
                            _controller.area?.name == _cities[i].name
                                ? Icon(Icons.check)
                                : null,
                        onTap: () => Navigator.pop(context, i),
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
    if (!mounted || selected == null) return;
    await _controller.selectArea(selected == -1 ? null : _cities[selected]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = widget.session.currentUser?.fullName.trim() ?? '';
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder:
              (context, _) => RefreshIndicator(
                onRefresh: _controller.refresh,
                child: CustomScrollView(
                  key: PageStorageKey('home-feed'),
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      key: Key('choose-area'),
                                      onPressed: _chooseArea,
                                      style: TextButton.styleFrom(
                                        foregroundColor: colors.onSurface,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 12,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.place_outlined,
                                        size: 20,
                                        color: colors.primary,
                                      ),
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              context.localizeMessage(
                                                _controller.areaLabel,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.expand_more, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.onProfile,
                                  tooltip: context.l10n.myProfile,
                                  icon: CircleAvatar(
                                    radius: 21,
                                    backgroundColor: colors.primaryContainer,
                                    child: Text(
                                      name.isEmpty
                                          ? context.l10n.me
                                          : name.characters.first.toUpperCase(),
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 22),
                            Text(
                              context.l10n.yourCityYourPeople,
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              context.l10n.goodThingsNstartNearby,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontSize: 31,
                                height: 1.12,
                                letterSpacing: -.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              context
                                  .l10n
                                  .discoverEventsMeetPeopleNandMakeADifferenceInYour,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                height: 1.5,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 24),
                            TextField(
                              key: Key('home-search'),
                              controller: _search,
                              onChanged: _controller.search,
                              maxLength: 120,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                _controller.loadFeed();
                              },
                              decoration: InputDecoration(
                                hintText: context.l10n.findAnEventOrAGoodCause,
                                counterText: '',
                                prefixIcon: Icon(Icons.search),
                                suffixIcon:
                                    _search.text.isEmpty
                                        ? null
                                        : IconButton(
                                          tooltip: context.l10n.clearSearch,
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            _search.clear();
                                            _controller.search('');
                                          },
                                        ),
                              ),
                            ),
                            SizedBox(height: 24),
                            _personalSection(),
                            SizedBox(height: 28),
                            _sectionTitle(
                              context.l10n.whatMattersToYou,
                              trailing: IconButton(
                                tooltip: context.l10n.advancedFilters,
                                icon: Icon(
                                  _controller.filters.isActive
                                      ? Icons.filter_alt
                                      : Icons.tune,
                                ),
                                onPressed: _openFilters,
                              ),
                            ),
                            SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _category(
                              null,
                              context.l10n.all360,
                              Icons.grid_view_rounded,
                            ),
                            for (final category in eventCategories)
                              _category(
                                category.value,
                                categoryLabel(
                                  category.value,
                                  strings: context.l10n,
                                ),
                                categoryIcon(category.value),
                              ),
                          ],
                        ),
                      ),
                    ),
                    ..._feedSlivers(),
                    SliverToBoxAdapter(child: SizedBox(height: 28)),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<MapFilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (_) => MapFiltersSheet(
            filters: _controller.filters,
            hasLocation: _controller.hasLocation,
          ),
    );
    if (mounted && result?.filters != null) {
      await _controller.applyFilters(result!.filters!);
    }
  }

  Widget _category(String? value, String label, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    final selected =
        value == null
            ? _controller.filters.categories.isEmpty
            : _controller.filters.categories.contains(value);
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        showCheckmark: false,
        selectedColor: colors.primary,
        backgroundColor: colors.surface,
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        avatar: Icon(
          icon,
          size: 18,
          color: selected ? colors.onPrimary : colors.onSurfaceVariant,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        onSelected: (_) => _controller.selectCategory(value),
      ),
    );
  }

  Widget _personalSection() {
    final colors = Theme.of(context).colorScheme;
    if (_controller.isLoadingPersonal) return _LoadingBlock(height: 144);
    if (_controller.personalError != null) {
      return _Notice(
        icon: Icons.event_busy_outlined,
        title: context.l10n.yourCalendarIsTemporarilyUnavailable,
        message: context.localizeMessage(_controller.personalError!),
        action: context.l10n.retry,
        onAction: _controller.loadPersonal,
      );
    }
    final event = _controller.nextEvent;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: AppGradients.accent(context)),
        child: InkWell(
          onTap: event == null ? widget.onCreate : () => _openEvent(event),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      event == null
                          ? Icons.auto_awesome_outlined
                          : Icons.event_available_outlined,
                      color: colors.onPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event == null
                            ? context.l10n.anIdeaForYourCommunity
                            : event.phaseAt(DateTime.now()) ==
                                EventPhase.ongoing
                            ? context.l10n.yourEventIsHappening
                            : event.phaseAt(DateTime.now()) == EventPhase.today
                            ? context.l10n.yourEventIsToday
                            : context.l10n.yourNextEvent,
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward,
                      color: colors.onPrimary,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  event?.title ??
                      context.l10n.bringPeopleTogetherNforAGoodCause,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  event == null
                      ? context.l10n.createEvent367
                      : '${eventDate(event)}\n${event.locationName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
        ),
      ),
      if (trailing != null) trailing,
    ],
  );

  List<Widget> _feedSlivers() {
    Widget block(Widget child) => SliverPadding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      sliver: SliverToBoxAdapter(child: child),
    );
    if (_controller.isLoading) {
      return [block(LoadingSkeleton())];
    }
    if (_controller.error != null) {
      return [
        block(
          _Notice(
            icon: Icons.cloud_off_outlined,
            title: context.l10n.couldNotLoadEvents,
            message: context.localizeMessage(_controller.error!),
            action: context.l10n.tryAgain,
            onAction: _controller.loadFeed,
          ),
        ),
      ];
    }
    final weekend = _controller.weekend;
    return [
      if (!_controller.hasLocation)
        block(
          _Notice(
            icon: Icons.location_off_outlined,
            title: context.l10n.letSFindYourCity,
            message:
                context
                    .l10n
                    .withoutLocationAccessWeShowEventsFromDifferentCities,
            action: context.l10n.chooseACity,
            onAction: _chooseArea,
          ),
        ),
      if (_controller.events.isEmpty)
        block(
          _Notice(
            icon: Icons.explore_outlined,
            title:
                _controller.hasFilters
                    ? context.l10n.noEventsMatchYourSearch
                    : context.l10n.itSQuietHereWantToStartSomething,
            message:
                _controller.hasFilters
                    ? context.l10n.tryDifferentWordsOrAnotherCategory
                    : context.l10n.createTheFirstInitiativeOrTryAnotherCity,
            action:
                _controller.hasFilters
                    ? context.l10n.resetFilters
                    : context.l10n.createEvent,
            onAction:
                _controller.hasFilters
                    ? () {
                      _search.clear();
                      _controller.clearFilters();
                    }
                    : widget.onCreate,
          ),
        ),
      if (!_controller.hasFilters && weekend.isNotEmpty) ...[
        block(
          _sectionTitle(
            context.l10n.thisWeekend,
            trailing: Icon(Icons.wb_sunny_outlined, size: 23),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 14),
            child: SizedBox(
              height: EventCard.featuredHeight(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: weekend.length,
                separatorBuilder: (_, _) => SizedBox(width: 12),
                itemBuilder:
                    (context, index) => SizedBox(
                      width: 286,
                      child: EventCard(
                        event: weekend[index],
                        featured: true,
                        onTap: () => _openEvent(weekend[index]),
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
      if (_controller.events.isNotEmpty) ...[
        block(
          _sectionTitle(
            _controller.hasFilters
                ? context.l10n.searchResults
                : _controller.hasLocation
                ? context.l10n.nearbyEvents
                : context.l10n.discoverSomethingNew,
            trailing: IconButton(
              tooltip: context.l10n.openMap,
              onPressed: widget.onMap,
              icon: Icon(Icons.map_outlined),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverList.separated(
            itemCount: _controller.events.length,
            separatorBuilder: (_, _) => SizedBox(height: 12),
            itemBuilder:
                (context, index) => EventCard(
                  event: _controller.events[index],
                  onTap: () => _openEvent(_controller.events[index]),
                ),
          ),
        ),
      ],
    ];
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loadingEvents,
    child: Container(
      height: height,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            height: 12,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          SizedBox(height: 18),
          Container(
            height: 20,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          SizedBox(height: 10),
          Container(
            width: 170,
            height: 12,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String title, message, action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}
