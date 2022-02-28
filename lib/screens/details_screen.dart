import 'package:flutter/material.dart';
import 'package:movies_application/models/movie.dart';
import 'package:movies_application/widgets/widgets.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context)?.settings.arguments as Movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(title: movie.title, posterUrl: movie.fullBackdropPath ?? movie.fullPosterImage,),
          SliverList(
            delegate: SliverChildListDelegate([
              PosterAndTitle(movie: movie,),
              Overview(overview: movie.overview,),
              CastingCards(movieId: movie.id,)
            ]),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String title;
  final String posterUrl;
  const CustomAppBar({Key? key, required this.title, required this.posterUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          color: Colors.black12,
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        ),
        background: FadeInImage(
          placeholder: const AssetImage('assets/loading.gif'),
          image: NetworkImage(posterUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class PosterAndTitle extends StatelessWidget {
  final Movie movie;
  const PosterAndTitle({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Hero(
          tag: movie.heroId ?? movie.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              placeholder: const AssetImage('assets/no-image.jpg'),
              image: NetworkImage(movie.fullPosterImage),
              height: 150,
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: textTheme.headline5,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Text(
                movie.originalTitle,
                style: textTheme.subtitle2,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_outline,
                    size: 15,
                    color: Colors.orange,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text('${movie.voteAverage}', style: textTheme.caption)
                ],
              )
            ],
          ),
        )
      ]),
    );
  }
}

class Overview extends StatelessWidget {
  final String overview;
  const Overview({Key? key, required this.overview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        overview,
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }
}
