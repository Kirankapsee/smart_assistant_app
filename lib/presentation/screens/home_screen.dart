import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../cubits/chat/chat_cubit.dart';
import '../cubits/suggestions/suggestions_cubit.dart';
import '../cubits/theme/theme_cubit.dart';
import '../widgets/common_widgets.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SuggestionsCubit>().fetchSuggestions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<SuggestionsCubit>().state;
    if (state is SuggestionsLoaded &&
        state.hasMore &&
        !state.isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      context.read<SuggestionsCubit>().loadNextPage();
    }
  }

  void _onSuggestionTap(String title, String description) {
    context.read<ChatCubit>().useSuggestion('$title – $description');
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () =>
            context.read<SuggestionsCubit>().fetchSuggestions(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(theme, isDark),
            _buildSubheader(theme),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surface,
      actions: [
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (_, s) => IconButton(
            tooltip: 'Toggle theme',
            icon: AnimatedSwitcher(
              duration: AppTheme.animationFast,
              child: Icon(
                s.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(s.isDark),
              ),
            ),
            onPressed: () => context.read<ThemeCubit>().toggle(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text('Smart Assistant',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppTheme.darkBg, AppTheme.darkSurface]
                  : [AppTheme.surface, const Color(0xFFEEECFF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What can I help',
                    style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary)),
                Text('you with today?',
                    style: theme.textTheme.displayMedium
                        ?.copyWith(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubheader(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: BlocBuilder<SuggestionsCubit, SuggestionsState>(
          buildWhen: (_, curr) => curr is SuggestionsLoaded,
          builder: (_, state) {
            if (state is! SuggestionsLoaded) return const SizedBox.shrink();
            return Text(
              '${state.pagination.totalItems} suggestions available',
              style: theme.textTheme.bodyMedium,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SuggestionsCubit, SuggestionsState>(
      builder: (context, state) {
        if (state is SuggestionsLoading) {
          return const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: SuggestionSkeleton()),
          );
        }
        if (state is SuggestionsError) {
          return SliverFillRemaining(
            child: ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<SuggestionsCubit>()
                  .fetchSuggestions(refresh: true),
            ),
          );
        }
        if (state is! SuggestionsLoaded) {
          return const SliverFillRemaining(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == state.suggestions.length) {
                  if (state.isLoadingMore) return const LoadMoreIndicator();
                  if (!state.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "You've seen it all! ✨",
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
                final s = state.suggestions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SuggestionCard(
                    suggestion: s,
                    onTap: () => _onSuggestionTap(s.title, s.description),
                  ),
                );
              },
              childCount: state.suggestions.length + 1,
            ),
          ),
        );
      },
    );
  }
}
