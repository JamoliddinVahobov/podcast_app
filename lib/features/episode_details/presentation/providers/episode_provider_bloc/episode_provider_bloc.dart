import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/features/episode_details/domain/usecases/episode_usecase.dart';
import '../../../../podcast_details/domain/entities/podcast_entity.dart';
import '../../../domain/entities/episode_entity.dart';
part 'episode_provider_event.dart';
part 'episode_provider_state.dart';

class EpisodeProviderBloc
    extends Bloc<EpisodeProviderEvent, EpisodeProviderState> {
  final FetchEpisodesUsecase _episodesUsecase;
  final int _limit = 21;

  EpisodeProviderBloc(
    Podcast podcast, {
    required FetchEpisodesUsecase episodesUsecase,
  })  : _episodesUsecase = episodesUsecase,
        super(EpisodeProviderState(
          podcast: podcast,
          currentOffset: 0,
        )) {
    on<LoadEpisodes>(_onLoadInitialEpisodes);
    on<LoadMoreEpisodes>(_onLoadMoreEpisodes);
  }

  Future<void> _onLoadInitialEpisodes(
      LoadEpisodes event, Emitter<EpisodeProviderState> emit) async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      error: null,
      currentOffset: 0,
    ));

    try {
      debugPrint('Fetching episodes for podcast ID: ${event.podcastId}');
      debugPrint('Using offset: , limit: $_limit');
      // The repository already returns List<Episode>, so we don't need to parse it again
      final episodes = await _episodesUsecase.fetchEpisodes(
        event.podcastId,
        offset: 0,
        limit: _limit,
      );

      debugPrint('Received ${episodes.length} initial episodes');

      emit(state.copyWith(
        episodes: episodes,
        isLoading: false,
        hasReachedMax: episodes.length < _limit,
        currentOffset: episodes.length,
        error: null,
      ));
    } catch (e, stackTrace) {
      debugPrint('Error in _onLoadPodcastDetails:');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load episodes: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadMoreEpisodes(
      LoadMoreEpisodes event, Emitter<EpisodeProviderState> emit) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      debugPrint('Fetching more episodes for podcast ID: ${event.podcastId}');
      debugPrint('Current offset: ${state.currentOffset}');

      // The repository already returns List<Episode>, so we don't need to parse it again
      final moreEpisodes = await _episodesUsecase.fetchEpisodes(
        event.podcastId,
        offset: state.currentOffset ?? 0,
        limit: _limit,
      );

      if (moreEpisodes.isEmpty) {
        emit(state.copyWith(
          hasReachedMax: true,
          isLoading: false,
        ));
        return;
      }

      final allEpisodes = [...state.episodes, ...moreEpisodes];
      final newOffset = (state.currentOffset ?? 0) + moreEpisodes.length;
      debugPrint('Total episodes after loading more: ${allEpisodes.length}');

      emit(state.copyWith(
        episodes: allEpisodes,
        currentOffset: newOffset,
        hasReachedMax: moreEpisodes.length < _limit,
        isLoading: false,
        error: null,
      ));
    } catch (e, stackTrace) {
      debugPrint('Error in _onLoadMoreEpisodes:');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      emit(state.copyWith(
        error: 'Failed to load more episodes: ${e.toString()}',
        isLoading: false,
      ));
    }
  }
}
