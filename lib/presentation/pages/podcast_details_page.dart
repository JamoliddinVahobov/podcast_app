import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/presentation/pages/fullscreen_player.dart';
import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/podcast_details_bloc/podcast_details_bloc.dart';

class PodcastDetailsPage extends StatelessWidget {
  final Map<String, dynamic> podcast;

  const PodcastDetailsPage({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PodcastDetailsBloc(podcast)..add(LoadPodcastDetails(podcast['id'])),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 235,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.sizeOf(context).width * 0.07,
                    ),
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            podcast['image'],
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast['name'],
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    if (podcast['publisher'] != '')
                      RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                            text: 'Publisher: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: podcast['publisher'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ]),
                      ),
                    const SizedBox(height: 10),
                    if (podcast['description'] != '')
                      RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                            text: 'Description: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: podcast['description'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ]),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Episodes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<PodcastDetailsBloc, PodcastDetailsState>(
              builder: (context, state) {
                return SliverList.builder(
                  itemCount: state.hasReachedMax
                      ? state.episodes.length
                      : state.episodes.length + 1,
                  itemBuilder: (context, index) {
                    // Check if this is the last item and load more if necessary
                    if (index == state.episodes.length) {
                      context
                          .read<PodcastDetailsBloc>()
                          .add(LoadMoreEpisodes(podcast['id']));
                      return const Center(child: CircularProgressIndicator());
                    }

                    final episode = state.episodes[index];
                    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                      builder: (context, audioState) {
                        final isCurrentlyPlaying =
                            audioState.currentEpisode?['id'] == episode['id'];

                        return ListTile(
                          title: Text(
                            episode['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Released in: ${episode['release_date']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isCurrentlyPlaying && audioState.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                            ),
                            onPressed: () {
                              final audioBloc = context.read<AudioPlayerBloc>();

                              if (isCurrentlyPlaying && audioState.isPlaying) {
                                audioBloc.add(PauseEpisode());
                              } else {
                                audioBloc.add(PlayEpisode(
                                  audioUrl: episode['audio_url'],
                                  episode: episode,
                                  podcast: podcast,
                                ));
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenPlayer(
                                  podcast: podcast,
                                  episode: episode,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            )
          ],
        ),
      ),
    );
  }
}