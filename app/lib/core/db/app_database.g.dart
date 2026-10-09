// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, SongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _youtubeIdMeta = const VerificationMeta(
    'youtubeId',
  );
  @override
  late final GeneratedColumn<String> youtubeId = GeneratedColumn<String>(
    'youtube_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('streamable'),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumArtUrlMeta = const VerificationMeta(
    'albumArtUrl',
  );
  @override
  late final GeneratedColumn<String> albumArtUrl = GeneratedColumn<String>(
    'album_art_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumArtPathMeta = const VerificationMeta(
    'albumArtPath',
  );
  @override
  late final GeneratedColumn<String> albumArtPath = GeneratedColumn<String>(
    'album_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artEmbeddedMeta = const VerificationMeta(
    'artEmbedded',
  );
  @override
  late final GeneratedColumn<bool> artEmbedded = GeneratedColumn<bool>(
    'art_embedded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("art_embedded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trackUriMeta = const VerificationMeta(
    'trackUri',
  );
  @override
  late final GeneratedColumn<String> trackUri = GeneratedColumn<String>(
    'track_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isrcMeta = const VerificationMeta('isrc');
  @override
  late final GeneratedColumn<String> isrc = GeneratedColumn<String>(
    'isrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _popularityMeta = const VerificationMeta(
    'popularity',
  );
  @override
  late final GeneratedColumn<int> popularity = GeneratedColumn<int>(
    'popularity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _danceabilityMeta = const VerificationMeta(
    'danceability',
  );
  @override
  late final GeneratedColumn<double> danceability = GeneratedColumn<double>(
    'danceability',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<double> energy = GeneratedColumn<double>(
    'energy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<int> key = GeneratedColumn<int>(
    'key',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loudnessMeta = const VerificationMeta(
    'loudness',
  );
  @override
  late final GeneratedColumn<double> loudness = GeneratedColumn<double>(
    'loudness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
    'mode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speechinessMeta = const VerificationMeta(
    'speechiness',
  );
  @override
  late final GeneratedColumn<double> speechiness = GeneratedColumn<double>(
    'speechiness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acousticnessMeta = const VerificationMeta(
    'acousticness',
  );
  @override
  late final GeneratedColumn<double> acousticness = GeneratedColumn<double>(
    'acousticness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instrumentalnessMeta = const VerificationMeta(
    'instrumentalness',
  );
  @override
  late final GeneratedColumn<double> instrumentalness = GeneratedColumn<double>(
    'instrumentalness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _livenessMeta = const VerificationMeta(
    'liveness',
  );
  @override
  late final GeneratedColumn<double> liveness = GeneratedColumn<double>(
    'liveness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valenceMeta = const VerificationMeta(
    'valence',
  );
  @override
  late final GeneratedColumn<double> valence = GeneratedColumn<double>(
    'valence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<double> tempo = GeneratedColumn<double>(
    'tempo',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeSignatureMeta = const VerificationMeta(
    'timeSignature',
  );
  @override
  late final GeneratedColumn<int> timeSignature = GeneratedColumn<int>(
    'time_signature',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepOrderMeta = const VerificationMeta(
    'sleepOrder',
  );
  @override
  late final GeneratedColumn<int> sleepOrder = GeneratedColumn<int>(
    'sleep_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noSleepOrderMeta = const VerificationMeta(
    'noSleepOrder',
  );
  @override
  late final GeneratedColumn<int> noSleepOrder = GeneratedColumn<int>(
    'no_sleep_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likedAtMeta = const VerificationMeta(
    'likedAt',
  );
  @override
  late final GeneratedColumn<DateTime> likedAt = GeneratedColumn<DateTime>(
    'liked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedYtTitleMeta = const VerificationMeta(
    'resolvedYtTitle',
  );
  @override
  late final GeneratedColumn<String> resolvedYtTitle = GeneratedColumn<String>(
    'resolved_yt_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filename,
    title,
    artist,
    album,
    youtubeId,
    localPath,
    status,
    durationMs,
    albumArtUrl,
    albumArtPath,
    artEmbedded,
    trackUri,
    isrc,
    trackNumber,
    explicit,
    popularity,
    genres,
    danceability,
    energy,
    key,
    loudness,
    mode,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    timeSignature,
    addedAt,
    sleepOrder,
    noSleepOrder,
    lastPlayedAt,
    playCount,
    likedAt,
    resolvedYtTitle,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('youtube_id')) {
      context.handle(
        _youtubeIdMeta,
        youtubeId.isAcceptableOrUnknown(data['youtube_id']!, _youtubeIdMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('album_art_url')) {
      context.handle(
        _albumArtUrlMeta,
        albumArtUrl.isAcceptableOrUnknown(
          data['album_art_url']!,
          _albumArtUrlMeta,
        ),
      );
    }
    if (data.containsKey('album_art_path')) {
      context.handle(
        _albumArtPathMeta,
        albumArtPath.isAcceptableOrUnknown(
          data['album_art_path']!,
          _albumArtPathMeta,
        ),
      );
    }
    if (data.containsKey('art_embedded')) {
      context.handle(
        _artEmbeddedMeta,
        artEmbedded.isAcceptableOrUnknown(
          data['art_embedded']!,
          _artEmbeddedMeta,
        ),
      );
    }
    if (data.containsKey('track_uri')) {
      context.handle(
        _trackUriMeta,
        trackUri.isAcceptableOrUnknown(data['track_uri']!, _trackUriMeta),
      );
    }
    if (data.containsKey('isrc')) {
      context.handle(
        _isrcMeta,
        isrc.isAcceptableOrUnknown(data['isrc']!, _isrcMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    if (data.containsKey('popularity')) {
      context.handle(
        _popularityMeta,
        popularity.isAcceptableOrUnknown(data['popularity']!, _popularityMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('danceability')) {
      context.handle(
        _danceabilityMeta,
        danceability.isAcceptableOrUnknown(
          data['danceability']!,
          _danceabilityMeta,
        ),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('loudness')) {
      context.handle(
        _loudnessMeta,
        loudness.isAcceptableOrUnknown(data['loudness']!, _loudnessMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('speechiness')) {
      context.handle(
        _speechinessMeta,
        speechiness.isAcceptableOrUnknown(
          data['speechiness']!,
          _speechinessMeta,
        ),
      );
    }
    if (data.containsKey('acousticness')) {
      context.handle(
        _acousticnessMeta,
        acousticness.isAcceptableOrUnknown(
          data['acousticness']!,
          _acousticnessMeta,
        ),
      );
    }
    if (data.containsKey('instrumentalness')) {
      context.handle(
        _instrumentalnessMeta,
        instrumentalness.isAcceptableOrUnknown(
          data['instrumentalness']!,
          _instrumentalnessMeta,
        ),
      );
    }
    if (data.containsKey('liveness')) {
      context.handle(
        _livenessMeta,
        liveness.isAcceptableOrUnknown(data['liveness']!, _livenessMeta),
      );
    }
    if (data.containsKey('valence')) {
      context.handle(
        _valenceMeta,
        valence.isAcceptableOrUnknown(data['valence']!, _valenceMeta),
      );
    }
    if (data.containsKey('tempo')) {
      context.handle(
        _tempoMeta,
        tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta),
      );
    }
    if (data.containsKey('time_signature')) {
      context.handle(
        _timeSignatureMeta,
        timeSignature.isAcceptableOrUnknown(
          data['time_signature']!,
          _timeSignatureMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('sleep_order')) {
      context.handle(
        _sleepOrderMeta,
        sleepOrder.isAcceptableOrUnknown(data['sleep_order']!, _sleepOrderMeta),
      );
    }
    if (data.containsKey('no_sleep_order')) {
      context.handle(
        _noSleepOrderMeta,
        noSleepOrder.isAcceptableOrUnknown(
          data['no_sleep_order']!,
          _noSleepOrderMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('liked_at')) {
      context.handle(
        _likedAtMeta,
        likedAt.isAcceptableOrUnknown(data['liked_at']!, _likedAtMeta),
      );
    }
    if (data.containsKey('resolved_yt_title')) {
      context.handle(
        _resolvedYtTitleMeta,
        resolvedYtTitle.isAcceptableOrUnknown(
          data['resolved_yt_title']!,
          _resolvedYtTitleMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      youtubeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      albumArtUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_art_url'],
      ),
      albumArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_art_path'],
      ),
      artEmbedded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}art_embedded'],
      )!,
      trackUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_uri'],
      ),
      isrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isrc'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      )!,
      popularity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}popularity'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      danceability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}danceability'],
      ),
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key'],
      ),
      loudness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loudness'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode'],
      ),
      speechiness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speechiness'],
      ),
      acousticness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acousticness'],
      ),
      instrumentalness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}instrumentalness'],
      ),
      liveness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liveness'],
      ),
      valence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valence'],
      ),
      tempo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tempo'],
      ),
      timeSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_signature'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
      sleepOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_order'],
      ),
      noSleepOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}no_sleep_order'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      likedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}liked_at'],
      ),
      resolvedYtTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_yt_title'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class SongRow extends DataClass implements Insertable<SongRow> {
  /// Primary key: zero-padded file index (e.g. "0000001") or spotify track uri
  /// for playlist-only songs.
  final String id;
  final String? filename;
  final String title;
  final String artist;
  final String? album;
  final String? youtubeId;
  final String? localPath;
  final String status;
  final int? durationMs;
  final String? albumArtUrl;
  final String? albumArtPath;
  final bool artEmbedded;
  final String? trackUri;
  final String? isrc;
  final int? trackNumber;
  final bool explicit;
  final int? popularity;
  final String? genres;
  final double? danceability;
  final double? energy;
  final int? key;
  final double? loudness;
  final int? mode;
  final double? speechiness;
  final double? acousticness;
  final double? instrumentalness;
  final double? liveness;
  final double? valence;
  final double? tempo;
  final int? timeSignature;
  final DateTime? addedAt;
  final int? sleepOrder;
  final int? noSleepOrder;
  final DateTime? lastPlayedAt;
  final int playCount;
  final DateTime? likedAt;
  final String? resolvedYtTitle;
  final String? error;
  const SongRow({
    required this.id,
    this.filename,
    required this.title,
    required this.artist,
    this.album,
    this.youtubeId,
    this.localPath,
    required this.status,
    this.durationMs,
    this.albumArtUrl,
    this.albumArtPath,
    required this.artEmbedded,
    this.trackUri,
    this.isrc,
    this.trackNumber,
    required this.explicit,
    this.popularity,
    this.genres,
    this.danceability,
    this.energy,
    this.key,
    this.loudness,
    this.mode,
    this.speechiness,
    this.acousticness,
    this.instrumentalness,
    this.liveness,
    this.valence,
    this.tempo,
    this.timeSignature,
    this.addedAt,
    this.sleepOrder,
    this.noSleepOrder,
    this.lastPlayedAt,
    required this.playCount,
    this.likedAt,
    this.resolvedYtTitle,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
    }
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || youtubeId != null) {
      map['youtube_id'] = Variable<String>(youtubeId);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || albumArtUrl != null) {
      map['album_art_url'] = Variable<String>(albumArtUrl);
    }
    if (!nullToAbsent || albumArtPath != null) {
      map['album_art_path'] = Variable<String>(albumArtPath);
    }
    map['art_embedded'] = Variable<bool>(artEmbedded);
    if (!nullToAbsent || trackUri != null) {
      map['track_uri'] = Variable<String>(trackUri);
    }
    if (!nullToAbsent || isrc != null) {
      map['isrc'] = Variable<String>(isrc);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    map['explicit'] = Variable<bool>(explicit);
    if (!nullToAbsent || popularity != null) {
      map['popularity'] = Variable<int>(popularity);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || danceability != null) {
      map['danceability'] = Variable<double>(danceability);
    }
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<double>(energy);
    }
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<int>(key);
    }
    if (!nullToAbsent || loudness != null) {
      map['loudness'] = Variable<double>(loudness);
    }
    if (!nullToAbsent || mode != null) {
      map['mode'] = Variable<int>(mode);
    }
    if (!nullToAbsent || speechiness != null) {
      map['speechiness'] = Variable<double>(speechiness);
    }
    if (!nullToAbsent || acousticness != null) {
      map['acousticness'] = Variable<double>(acousticness);
    }
    if (!nullToAbsent || instrumentalness != null) {
      map['instrumentalness'] = Variable<double>(instrumentalness);
    }
    if (!nullToAbsent || liveness != null) {
      map['liveness'] = Variable<double>(liveness);
    }
    if (!nullToAbsent || valence != null) {
      map['valence'] = Variable<double>(valence);
    }
    if (!nullToAbsent || tempo != null) {
      map['tempo'] = Variable<double>(tempo);
    }
    if (!nullToAbsent || timeSignature != null) {
      map['time_signature'] = Variable<int>(timeSignature);
    }
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    if (!nullToAbsent || sleepOrder != null) {
      map['sleep_order'] = Variable<int>(sleepOrder);
    }
    if (!nullToAbsent || noSleepOrder != null) {
      map['no_sleep_order'] = Variable<int>(noSleepOrder);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || likedAt != null) {
      map['liked_at'] = Variable<DateTime>(likedAt);
    }
    if (!nullToAbsent || resolvedYtTitle != null) {
      map['resolved_yt_title'] = Variable<String>(resolvedYtTitle);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
      title: Value(title),
      artist: Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      youtubeId: youtubeId == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      status: Value(status),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      albumArtUrl: albumArtUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtUrl),
      albumArtPath: albumArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtPath),
      artEmbedded: Value(artEmbedded),
      trackUri: trackUri == null && nullToAbsent
          ? const Value.absent()
          : Value(trackUri),
      isrc: isrc == null && nullToAbsent ? const Value.absent() : Value(isrc),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      explicit: Value(explicit),
      popularity: popularity == null && nullToAbsent
          ? const Value.absent()
          : Value(popularity),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      danceability: danceability == null && nullToAbsent
          ? const Value.absent()
          : Value(danceability),
      energy: energy == null && nullToAbsent
          ? const Value.absent()
          : Value(energy),
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      loudness: loudness == null && nullToAbsent
          ? const Value.absent()
          : Value(loudness),
      mode: mode == null && nullToAbsent ? const Value.absent() : Value(mode),
      speechiness: speechiness == null && nullToAbsent
          ? const Value.absent()
          : Value(speechiness),
      acousticness: acousticness == null && nullToAbsent
          ? const Value.absent()
          : Value(acousticness),
      instrumentalness: instrumentalness == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentalness),
      liveness: liveness == null && nullToAbsent
          ? const Value.absent()
          : Value(liveness),
      valence: valence == null && nullToAbsent
          ? const Value.absent()
          : Value(valence),
      tempo: tempo == null && nullToAbsent
          ? const Value.absent()
          : Value(tempo),
      timeSignature: timeSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSignature),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
      sleepOrder: sleepOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepOrder),
      noSleepOrder: noSleepOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(noSleepOrder),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      playCount: Value(playCount),
      likedAt: likedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(likedAt),
      resolvedYtTitle: resolvedYtTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedYtTitle),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory SongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongRow(
      id: serializer.fromJson<String>(json['id']),
      filename: serializer.fromJson<String?>(json['filename']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      youtubeId: serializer.fromJson<String?>(json['youtubeId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      status: serializer.fromJson<String>(json['status']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      albumArtUrl: serializer.fromJson<String?>(json['albumArtUrl']),
      albumArtPath: serializer.fromJson<String?>(json['albumArtPath']),
      artEmbedded: serializer.fromJson<bool>(json['artEmbedded']),
      trackUri: serializer.fromJson<String?>(json['trackUri']),
      isrc: serializer.fromJson<String?>(json['isrc']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      explicit: serializer.fromJson<bool>(json['explicit']),
      popularity: serializer.fromJson<int?>(json['popularity']),
      genres: serializer.fromJson<String?>(json['genres']),
      danceability: serializer.fromJson<double?>(json['danceability']),
      energy: serializer.fromJson<double?>(json['energy']),
      key: serializer.fromJson<int?>(json['key']),
      loudness: serializer.fromJson<double?>(json['loudness']),
      mode: serializer.fromJson<int?>(json['mode']),
      speechiness: serializer.fromJson<double?>(json['speechiness']),
      acousticness: serializer.fromJson<double?>(json['acousticness']),
      instrumentalness: serializer.fromJson<double?>(json['instrumentalness']),
      liveness: serializer.fromJson<double?>(json['liveness']),
      valence: serializer.fromJson<double?>(json['valence']),
      tempo: serializer.fromJson<double?>(json['tempo']),
      timeSignature: serializer.fromJson<int?>(json['timeSignature']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      sleepOrder: serializer.fromJson<int?>(json['sleepOrder']),
      noSleepOrder: serializer.fromJson<int?>(json['noSleepOrder']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      playCount: serializer.fromJson<int>(json['playCount']),
      likedAt: serializer.fromJson<DateTime?>(json['likedAt']),
      resolvedYtTitle: serializer.fromJson<String?>(json['resolvedYtTitle']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filename': serializer.toJson<String?>(filename),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String?>(album),
      'youtubeId': serializer.toJson<String?>(youtubeId),
      'localPath': serializer.toJson<String?>(localPath),
      'status': serializer.toJson<String>(status),
      'durationMs': serializer.toJson<int?>(durationMs),
      'albumArtUrl': serializer.toJson<String?>(albumArtUrl),
      'albumArtPath': serializer.toJson<String?>(albumArtPath),
      'artEmbedded': serializer.toJson<bool>(artEmbedded),
      'trackUri': serializer.toJson<String?>(trackUri),
      'isrc': serializer.toJson<String?>(isrc),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'explicit': serializer.toJson<bool>(explicit),
      'popularity': serializer.toJson<int?>(popularity),
      'genres': serializer.toJson<String?>(genres),
      'danceability': serializer.toJson<double?>(danceability),
      'energy': serializer.toJson<double?>(energy),
      'key': serializer.toJson<int?>(key),
      'loudness': serializer.toJson<double?>(loudness),
      'mode': serializer.toJson<int?>(mode),
      'speechiness': serializer.toJson<double?>(speechiness),
      'acousticness': serializer.toJson<double?>(acousticness),
      'instrumentalness': serializer.toJson<double?>(instrumentalness),
      'liveness': serializer.toJson<double?>(liveness),
      'valence': serializer.toJson<double?>(valence),
      'tempo': serializer.toJson<double?>(tempo),
      'timeSignature': serializer.toJson<int?>(timeSignature),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'sleepOrder': serializer.toJson<int?>(sleepOrder),
      'noSleepOrder': serializer.toJson<int?>(noSleepOrder),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'playCount': serializer.toJson<int>(playCount),
      'likedAt': serializer.toJson<DateTime?>(likedAt),
      'resolvedYtTitle': serializer.toJson<String?>(resolvedYtTitle),
      'error': serializer.toJson<String?>(error),
    };
  }

  SongRow copyWith({
    String? id,
    Value<String?> filename = const Value.absent(),
    String? title,
    String? artist,
    Value<String?> album = const Value.absent(),
    Value<String?> youtubeId = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    String? status,
    Value<int?> durationMs = const Value.absent(),
    Value<String?> albumArtUrl = const Value.absent(),
    Value<String?> albumArtPath = const Value.absent(),
    bool? artEmbedded,
    Value<String?> trackUri = const Value.absent(),
    Value<String?> isrc = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    bool? explicit,
    Value<int?> popularity = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<double?> danceability = const Value.absent(),
    Value<double?> energy = const Value.absent(),
    Value<int?> key = const Value.absent(),
    Value<double?> loudness = const Value.absent(),
    Value<int?> mode = const Value.absent(),
    Value<double?> speechiness = const Value.absent(),
    Value<double?> acousticness = const Value.absent(),
    Value<double?> instrumentalness = const Value.absent(),
    Value<double?> liveness = const Value.absent(),
    Value<double?> valence = const Value.absent(),
    Value<double?> tempo = const Value.absent(),
    Value<int?> timeSignature = const Value.absent(),
    Value<DateTime?> addedAt = const Value.absent(),
    Value<int?> sleepOrder = const Value.absent(),
    Value<int?> noSleepOrder = const Value.absent(),
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    int? playCount,
    Value<DateTime?> likedAt = const Value.absent(),
    Value<String?> resolvedYtTitle = const Value.absent(),
    Value<String?> error = const Value.absent(),
  }) => SongRow(
    id: id ?? this.id,
    filename: filename.present ? filename.value : this.filename,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album.present ? album.value : this.album,
    youtubeId: youtubeId.present ? youtubeId.value : this.youtubeId,
    localPath: localPath.present ? localPath.value : this.localPath,
    status: status ?? this.status,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    albumArtUrl: albumArtUrl.present ? albumArtUrl.value : this.albumArtUrl,
    albumArtPath: albumArtPath.present ? albumArtPath.value : this.albumArtPath,
    artEmbedded: artEmbedded ?? this.artEmbedded,
    trackUri: trackUri.present ? trackUri.value : this.trackUri,
    isrc: isrc.present ? isrc.value : this.isrc,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    explicit: explicit ?? this.explicit,
    popularity: popularity.present ? popularity.value : this.popularity,
    genres: genres.present ? genres.value : this.genres,
    danceability: danceability.present ? danceability.value : this.danceability,
    energy: energy.present ? energy.value : this.energy,
    key: key.present ? key.value : this.key,
    loudness: loudness.present ? loudness.value : this.loudness,
    mode: mode.present ? mode.value : this.mode,
    speechiness: speechiness.present ? speechiness.value : this.speechiness,
    acousticness: acousticness.present ? acousticness.value : this.acousticness,
    instrumentalness: instrumentalness.present
        ? instrumentalness.value
        : this.instrumentalness,
    liveness: liveness.present ? liveness.value : this.liveness,
    valence: valence.present ? valence.value : this.valence,
    tempo: tempo.present ? tempo.value : this.tempo,
    timeSignature: timeSignature.present
        ? timeSignature.value
        : this.timeSignature,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    sleepOrder: sleepOrder.present ? sleepOrder.value : this.sleepOrder,
    noSleepOrder: noSleepOrder.present ? noSleepOrder.value : this.noSleepOrder,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    playCount: playCount ?? this.playCount,
    likedAt: likedAt.present ? likedAt.value : this.likedAt,
    resolvedYtTitle: resolvedYtTitle.present
        ? resolvedYtTitle.value
        : this.resolvedYtTitle,
    error: error.present ? error.value : this.error,
  );
  SongRow copyWithCompanion(SongsCompanion data) {
    return SongRow(
      id: data.id.present ? data.id.value : this.id,
      filename: data.filename.present ? data.filename.value : this.filename,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      youtubeId: data.youtubeId.present ? data.youtubeId.value : this.youtubeId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      status: data.status.present ? data.status.value : this.status,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      albumArtUrl: data.albumArtUrl.present
          ? data.albumArtUrl.value
          : this.albumArtUrl,
      albumArtPath: data.albumArtPath.present
          ? data.albumArtPath.value
          : this.albumArtPath,
      artEmbedded: data.artEmbedded.present
          ? data.artEmbedded.value
          : this.artEmbedded,
      trackUri: data.trackUri.present ? data.trackUri.value : this.trackUri,
      isrc: data.isrc.present ? data.isrc.value : this.isrc,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
      popularity: data.popularity.present
          ? data.popularity.value
          : this.popularity,
      genres: data.genres.present ? data.genres.value : this.genres,
      danceability: data.danceability.present
          ? data.danceability.value
          : this.danceability,
      energy: data.energy.present ? data.energy.value : this.energy,
      key: data.key.present ? data.key.value : this.key,
      loudness: data.loudness.present ? data.loudness.value : this.loudness,
      mode: data.mode.present ? data.mode.value : this.mode,
      speechiness: data.speechiness.present
          ? data.speechiness.value
          : this.speechiness,
      acousticness: data.acousticness.present
          ? data.acousticness.value
          : this.acousticness,
      instrumentalness: data.instrumentalness.present
          ? data.instrumentalness.value
          : this.instrumentalness,
      liveness: data.liveness.present ? data.liveness.value : this.liveness,
      valence: data.valence.present ? data.valence.value : this.valence,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      timeSignature: data.timeSignature.present
          ? data.timeSignature.value
          : this.timeSignature,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      sleepOrder: data.sleepOrder.present
          ? data.sleepOrder.value
          : this.sleepOrder,
      noSleepOrder: data.noSleepOrder.present
          ? data.noSleepOrder.value
          : this.noSleepOrder,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      likedAt: data.likedAt.present ? data.likedAt.value : this.likedAt,
      resolvedYtTitle: data.resolvedYtTitle.present
          ? data.resolvedYtTitle.value
          : this.resolvedYtTitle,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongRow(')
          ..write('id: $id, ')
          ..write('filename: $filename, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('localPath: $localPath, ')
          ..write('status: $status, ')
          ..write('durationMs: $durationMs, ')
          ..write('albumArtUrl: $albumArtUrl, ')
          ..write('albumArtPath: $albumArtPath, ')
          ..write('artEmbedded: $artEmbedded, ')
          ..write('trackUri: $trackUri, ')
          ..write('isrc: $isrc, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('explicit: $explicit, ')
          ..write('popularity: $popularity, ')
          ..write('genres: $genres, ')
          ..write('danceability: $danceability, ')
          ..write('energy: $energy, ')
          ..write('key: $key, ')
          ..write('loudness: $loudness, ')
          ..write('mode: $mode, ')
          ..write('speechiness: $speechiness, ')
          ..write('acousticness: $acousticness, ')
          ..write('instrumentalness: $instrumentalness, ')
          ..write('liveness: $liveness, ')
          ..write('valence: $valence, ')
          ..write('tempo: $tempo, ')
          ..write('timeSignature: $timeSignature, ')
          ..write('addedAt: $addedAt, ')
          ..write('sleepOrder: $sleepOrder, ')
          ..write('noSleepOrder: $noSleepOrder, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount, ')
          ..write('likedAt: $likedAt, ')
          ..write('resolvedYtTitle: $resolvedYtTitle, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    filename,
    title,
    artist,
    album,
    youtubeId,
    localPath,
    status,
    durationMs,
    albumArtUrl,
    albumArtPath,
    artEmbedded,
    trackUri,
    isrc,
    trackNumber,
    explicit,
    popularity,
    genres,
    danceability,
    energy,
    key,
    loudness,
    mode,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    timeSignature,
    addedAt,
    sleepOrder,
    noSleepOrder,
    lastPlayedAt,
    playCount,
    likedAt,
    resolvedYtTitle,
    error,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongRow &&
          other.id == this.id &&
          other.filename == this.filename &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.youtubeId == this.youtubeId &&
          other.localPath == this.localPath &&
          other.status == this.status &&
          other.durationMs == this.durationMs &&
          other.albumArtUrl == this.albumArtUrl &&
          other.albumArtPath == this.albumArtPath &&
          other.artEmbedded == this.artEmbedded &&
          other.trackUri == this.trackUri &&
          other.isrc == this.isrc &&
          other.trackNumber == this.trackNumber &&
          other.explicit == this.explicit &&
          other.popularity == this.popularity &&
          other.genres == this.genres &&
          other.danceability == this.danceability &&
          other.energy == this.energy &&
          other.key == this.key &&
          other.loudness == this.loudness &&
          other.mode == this.mode &&
          other.speechiness == this.speechiness &&
          other.acousticness == this.acousticness &&
          other.instrumentalness == this.instrumentalness &&
          other.liveness == this.liveness &&
          other.valence == this.valence &&
          other.tempo == this.tempo &&
          other.timeSignature == this.timeSignature &&
          other.addedAt == this.addedAt &&
          other.sleepOrder == this.sleepOrder &&
          other.noSleepOrder == this.noSleepOrder &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.playCount == this.playCount &&
          other.likedAt == this.likedAt &&
          other.resolvedYtTitle == this.resolvedYtTitle &&
          other.error == this.error);
}

class SongsCompanion extends UpdateCompanion<SongRow> {
  final Value<String> id;
  final Value<String?> filename;
  final Value<String> title;
  final Value<String> artist;
  final Value<String?> album;
  final Value<String?> youtubeId;
  final Value<String?> localPath;
  final Value<String> status;
  final Value<int?> durationMs;
  final Value<String?> albumArtUrl;
  final Value<String?> albumArtPath;
  final Value<bool> artEmbedded;
  final Value<String?> trackUri;
  final Value<String?> isrc;
  final Value<int?> trackNumber;
  final Value<bool> explicit;
  final Value<int?> popularity;
  final Value<String?> genres;
  final Value<double?> danceability;
  final Value<double?> energy;
  final Value<int?> key;
  final Value<double?> loudness;
  final Value<int?> mode;
  final Value<double?> speechiness;
  final Value<double?> acousticness;
  final Value<double?> instrumentalness;
  final Value<double?> liveness;
  final Value<double?> valence;
  final Value<double?> tempo;
  final Value<int?> timeSignature;
  final Value<DateTime?> addedAt;
  final Value<int?> sleepOrder;
  final Value<int?> noSleepOrder;
  final Value<DateTime?> lastPlayedAt;
  final Value<int> playCount;
  final Value<DateTime?> likedAt;
  final Value<String?> resolvedYtTitle;
  final Value<String?> error;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.filename = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.youtubeId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.status = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.albumArtUrl = const Value.absent(),
    this.albumArtPath = const Value.absent(),
    this.artEmbedded = const Value.absent(),
    this.trackUri = const Value.absent(),
    this.isrc = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.explicit = const Value.absent(),
    this.popularity = const Value.absent(),
    this.genres = const Value.absent(),
    this.danceability = const Value.absent(),
    this.energy = const Value.absent(),
    this.key = const Value.absent(),
    this.loudness = const Value.absent(),
    this.mode = const Value.absent(),
    this.speechiness = const Value.absent(),
    this.acousticness = const Value.absent(),
    this.instrumentalness = const Value.absent(),
    this.liveness = const Value.absent(),
    this.valence = const Value.absent(),
    this.tempo = const Value.absent(),
    this.timeSignature = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.sleepOrder = const Value.absent(),
    this.noSleepOrder = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.resolvedYtTitle = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    this.filename = const Value.absent(),
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.youtubeId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.status = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.albumArtUrl = const Value.absent(),
    this.albumArtPath = const Value.absent(),
    this.artEmbedded = const Value.absent(),
    this.trackUri = const Value.absent(),
    this.isrc = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.explicit = const Value.absent(),
    this.popularity = const Value.absent(),
    this.genres = const Value.absent(),
    this.danceability = const Value.absent(),
    this.energy = const Value.absent(),
    this.key = const Value.absent(),
    this.loudness = const Value.absent(),
    this.mode = const Value.absent(),
    this.speechiness = const Value.absent(),
    this.acousticness = const Value.absent(),
    this.instrumentalness = const Value.absent(),
    this.liveness = const Value.absent(),
    this.valence = const Value.absent(),
    this.tempo = const Value.absent(),
    this.timeSignature = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.sleepOrder = const Value.absent(),
    this.noSleepOrder = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.resolvedYtTitle = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<SongRow> custom({
    Expression<String>? id,
    Expression<String>? filename,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? youtubeId,
    Expression<String>? localPath,
    Expression<String>? status,
    Expression<int>? durationMs,
    Expression<String>? albumArtUrl,
    Expression<String>? albumArtPath,
    Expression<bool>? artEmbedded,
    Expression<String>? trackUri,
    Expression<String>? isrc,
    Expression<int>? trackNumber,
    Expression<bool>? explicit,
    Expression<int>? popularity,
    Expression<String>? genres,
    Expression<double>? danceability,
    Expression<double>? energy,
    Expression<int>? key,
    Expression<double>? loudness,
    Expression<int>? mode,
    Expression<double>? speechiness,
    Expression<double>? acousticness,
    Expression<double>? instrumentalness,
    Expression<double>? liveness,
    Expression<double>? valence,
    Expression<double>? tempo,
    Expression<int>? timeSignature,
    Expression<DateTime>? addedAt,
    Expression<int>? sleepOrder,
    Expression<int>? noSleepOrder,
    Expression<DateTime>? lastPlayedAt,
    Expression<int>? playCount,
    Expression<DateTime>? likedAt,
    Expression<String>? resolvedYtTitle,
    Expression<String>? error,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filename != null) 'filename': filename,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (youtubeId != null) 'youtube_id': youtubeId,
      if (localPath != null) 'local_path': localPath,
      if (status != null) 'status': status,
      if (durationMs != null) 'duration_ms': durationMs,
      if (albumArtUrl != null) 'album_art_url': albumArtUrl,
      if (albumArtPath != null) 'album_art_path': albumArtPath,
      if (artEmbedded != null) 'art_embedded': artEmbedded,
      if (trackUri != null) 'track_uri': trackUri,
      if (isrc != null) 'isrc': isrc,
      if (trackNumber != null) 'track_number': trackNumber,
      if (explicit != null) 'explicit': explicit,
      if (popularity != null) 'popularity': popularity,
      if (genres != null) 'genres': genres,
      if (danceability != null) 'danceability': danceability,
      if (energy != null) 'energy': energy,
      if (key != null) 'key': key,
      if (loudness != null) 'loudness': loudness,
      if (mode != null) 'mode': mode,
      if (speechiness != null) 'speechiness': speechiness,
      if (acousticness != null) 'acousticness': acousticness,
      if (instrumentalness != null) 'instrumentalness': instrumentalness,
      if (liveness != null) 'liveness': liveness,
      if (valence != null) 'valence': valence,
      if (tempo != null) 'tempo': tempo,
      if (timeSignature != null) 'time_signature': timeSignature,
      if (addedAt != null) 'added_at': addedAt,
      if (sleepOrder != null) 'sleep_order': sleepOrder,
      if (noSleepOrder != null) 'no_sleep_order': noSleepOrder,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (playCount != null) 'play_count': playCount,
      if (likedAt != null) 'liked_at': likedAt,
      if (resolvedYtTitle != null) 'resolved_yt_title': resolvedYtTitle,
      if (error != null) 'error': error,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<String?>? filename,
    Value<String>? title,
    Value<String>? artist,
    Value<String?>? album,
    Value<String?>? youtubeId,
    Value<String?>? localPath,
    Value<String>? status,
    Value<int?>? durationMs,
    Value<String?>? albumArtUrl,
    Value<String?>? albumArtPath,
    Value<bool>? artEmbedded,
    Value<String?>? trackUri,
    Value<String?>? isrc,
    Value<int?>? trackNumber,
    Value<bool>? explicit,
    Value<int?>? popularity,
    Value<String?>? genres,
    Value<double?>? danceability,
    Value<double?>? energy,
    Value<int?>? key,
    Value<double?>? loudness,
    Value<int?>? mode,
    Value<double?>? speechiness,
    Value<double?>? acousticness,
    Value<double?>? instrumentalness,
    Value<double?>? liveness,
    Value<double?>? valence,
    Value<double?>? tempo,
    Value<int?>? timeSignature,
    Value<DateTime?>? addedAt,
    Value<int?>? sleepOrder,
    Value<int?>? noSleepOrder,
    Value<DateTime?>? lastPlayedAt,
    Value<int>? playCount,
    Value<DateTime?>? likedAt,
    Value<String?>? resolvedYtTitle,
    Value<String?>? error,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      youtubeId: youtubeId ?? this.youtubeId,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      artEmbedded: artEmbedded ?? this.artEmbedded,
      trackUri: trackUri ?? this.trackUri,
      isrc: isrc ?? this.isrc,
      trackNumber: trackNumber ?? this.trackNumber,
      explicit: explicit ?? this.explicit,
      popularity: popularity ?? this.popularity,
      genres: genres ?? this.genres,
      danceability: danceability ?? this.danceability,
      energy: energy ?? this.energy,
      key: key ?? this.key,
      loudness: loudness ?? this.loudness,
      mode: mode ?? this.mode,
      speechiness: speechiness ?? this.speechiness,
      acousticness: acousticness ?? this.acousticness,
      instrumentalness: instrumentalness ?? this.instrumentalness,
      liveness: liveness ?? this.liveness,
      valence: valence ?? this.valence,
      tempo: tempo ?? this.tempo,
      timeSignature: timeSignature ?? this.timeSignature,
      addedAt: addedAt ?? this.addedAt,
      sleepOrder: sleepOrder ?? this.sleepOrder,
      noSleepOrder: noSleepOrder ?? this.noSleepOrder,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      likedAt: likedAt ?? this.likedAt,
      resolvedYtTitle: resolvedYtTitle ?? this.resolvedYtTitle,
      error: error ?? this.error,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (youtubeId.present) {
      map['youtube_id'] = Variable<String>(youtubeId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (albumArtUrl.present) {
      map['album_art_url'] = Variable<String>(albumArtUrl.value);
    }
    if (albumArtPath.present) {
      map['album_art_path'] = Variable<String>(albumArtPath.value);
    }
    if (artEmbedded.present) {
      map['art_embedded'] = Variable<bool>(artEmbedded.value);
    }
    if (trackUri.present) {
      map['track_uri'] = Variable<String>(trackUri.value);
    }
    if (isrc.present) {
      map['isrc'] = Variable<String>(isrc.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<int>(popularity.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (danceability.present) {
      map['danceability'] = Variable<double>(danceability.value);
    }
    if (energy.present) {
      map['energy'] = Variable<double>(energy.value);
    }
    if (key.present) {
      map['key'] = Variable<int>(key.value);
    }
    if (loudness.present) {
      map['loudness'] = Variable<double>(loudness.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (speechiness.present) {
      map['speechiness'] = Variable<double>(speechiness.value);
    }
    if (acousticness.present) {
      map['acousticness'] = Variable<double>(acousticness.value);
    }
    if (instrumentalness.present) {
      map['instrumentalness'] = Variable<double>(instrumentalness.value);
    }
    if (liveness.present) {
      map['liveness'] = Variable<double>(liveness.value);
    }
    if (valence.present) {
      map['valence'] = Variable<double>(valence.value);
    }
    if (tempo.present) {
      map['tempo'] = Variable<double>(tempo.value);
    }
    if (timeSignature.present) {
      map['time_signature'] = Variable<int>(timeSignature.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (sleepOrder.present) {
      map['sleep_order'] = Variable<int>(sleepOrder.value);
    }
    if (noSleepOrder.present) {
      map['no_sleep_order'] = Variable<int>(noSleepOrder.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (likedAt.present) {
      map['liked_at'] = Variable<DateTime>(likedAt.value);
    }
    if (resolvedYtTitle.present) {
      map['resolved_yt_title'] = Variable<String>(resolvedYtTitle.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('filename: $filename, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('localPath: $localPath, ')
          ..write('status: $status, ')
          ..write('durationMs: $durationMs, ')
          ..write('albumArtUrl: $albumArtUrl, ')
          ..write('albumArtPath: $albumArtPath, ')
          ..write('artEmbedded: $artEmbedded, ')
          ..write('trackUri: $trackUri, ')
          ..write('isrc: $isrc, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('explicit: $explicit, ')
          ..write('popularity: $popularity, ')
          ..write('genres: $genres, ')
          ..write('danceability: $danceability, ')
          ..write('energy: $energy, ')
          ..write('key: $key, ')
          ..write('loudness: $loudness, ')
          ..write('mode: $mode, ')
          ..write('speechiness: $speechiness, ')
          ..write('acousticness: $acousticness, ')
          ..write('instrumentalness: $instrumentalness, ')
          ..write('liveness: $liveness, ')
          ..write('valence: $valence, ')
          ..write('tempo: $tempo, ')
          ..write('timeSignature: $timeSignature, ')
          ..write('addedAt: $addedAt, ')
          ..write('sleepOrder: $sleepOrder, ')
          ..write('noSleepOrder: $noSleepOrder, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount, ')
          ..write('likedAt: $likedAt, ')
          ..write('resolvedYtTitle: $resolvedYtTitle, ')
          ..write('error: $error, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LyricsTableTable extends LyricsTable
    with TableInfo<$LyricsTableTable, LyricsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, type, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  LyricsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsTableData(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $LyricsTableTable createAlias(String alias) {
    return $LyricsTableTable(attachedDatabase, alias);
  }
}

class LyricsTableData extends DataClass implements Insertable<LyricsTableData> {
  final String songId;

  /// 'lrc' (synced) or 'txt' (plain).
  final String type;
  final String content;
  const LyricsTableData({
    required this.songId,
    required this.type,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    return map;
  }

  LyricsTableCompanion toCompanion(bool nullToAbsent) {
    return LyricsTableCompanion(
      songId: Value(songId),
      type: Value(type),
      content: Value(content),
    );
  }

  factory LyricsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsTableData(
      songId: serializer.fromJson<String>(json['songId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
    };
  }

  LyricsTableData copyWith({String? songId, String? type, String? content}) =>
      LyricsTableData(
        songId: songId ?? this.songId,
        type: type ?? this.type,
        content: content ?? this.content,
      );
  LyricsTableData copyWithCompanion(LyricsTableCompanion data) {
    return LyricsTableData(
      songId: data.songId.present ? data.songId.value : this.songId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTableData(')
          ..write('songId: $songId, ')
          ..write('type: $type, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, type, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsTableData &&
          other.songId == this.songId &&
          other.type == this.type &&
          other.content == this.content);
}

class LyricsTableCompanion extends UpdateCompanion<LyricsTableData> {
  final Value<String> songId;
  final Value<String> type;
  final Value<String> content;
  final Value<int> rowid;
  const LyricsTableCompanion({
    this.songId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricsTableCompanion.insert({
    required String songId,
    required String type,
    required String content,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       type = Value(type),
       content = Value(content);
  static Insertable<LyricsTableData> custom({
    Expression<String>? songId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricsTableCompanion copyWith({
    Value<String>? songId,
    Value<String>? type,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return LyricsTableCompanion(
      songId: songId ?? this.songId,
      type: type ?? this.type,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTableCompanion(')
          ..write('songId: $songId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  /// 'sleep' / 'no_sleep' for the seeded playlists, 'pl_[timestamp]' for user ones.
  final String id;
  final String name;
  final DateTime createdAt;
  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Playlist copyWith({String? id, String? name, DateTime? createdAt}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTable extends PlaylistSongs
    with TableInfo<$PlaylistSongsTable, PlaylistSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSong(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistSongsTable createAlias(String alias) {
    return $PlaylistSongsTable(attachedDatabase, alias);
  }
}

class PlaylistSong extends DataClass implements Insertable<PlaylistSong> {
  final String playlistId;
  final String songId;
  final int position;
  const PlaylistSong({
    required this.playlistId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory PlaylistSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSong(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistSong copyWith({String? playlistId, String? songId, int? position}) =>
      PlaylistSong(
        playlistId: playlistId ?? this.playlistId,
        songId: songId ?? this.songId,
        position: position ?? this.position,
      );
  PlaylistSong copyWithCompanion(PlaylistSongsCompanion data) {
    return PlaylistSong(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSong(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSong &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSong> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistSongsCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    required String playlistId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<PlaylistSong> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongsCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaylistSongsCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListeningSessionsTable extends ListeningSessions
    with TableInfo<$ListeningSessionsTable, ListeningSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActivityAtMeta = const VerificationMeta(
    'lastActivityAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivityAt =
      GeneratedColumn<DateTime>(
        'last_activity_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    lastActivityAt,
    endedAt,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_activity_at')) {
      context.handle(
        _lastActivityAtMeta,
        lastActivityAt.isAcceptableOrUnknown(
          data['last_activity_at']!,
          _lastActivityAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActivityAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastActivityAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $ListeningSessionsTable createAlias(String alias) {
    return $ListeningSessionsTable(attachedDatabase, alias);
  }
}

class ListeningSession extends DataClass
    implements Insertable<ListeningSession> {
  final String id;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final DateTime? endedAt;

  /// 'active' or 'completed'
  final String state;
  const ListeningSession({
    required this.id,
    required this.startedAt,
    required this.lastActivityAt,
    this.endedAt,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['last_activity_at'] = Variable<DateTime>(lastActivityAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['state'] = Variable<String>(state);
    return map;
  }

  ListeningSessionsCompanion toCompanion(bool nullToAbsent) {
    return ListeningSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      lastActivityAt: Value(lastActivityAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      state: Value(state),
    );
  }

  factory ListeningSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningSession(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastActivityAt: serializer.fromJson<DateTime>(json['lastActivityAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastActivityAt': serializer.toJson<DateTime>(lastActivityAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'state': serializer.toJson<String>(state),
    };
  }

  ListeningSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? state,
  }) => ListeningSession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    state: state ?? this.state,
  );
  ListeningSession copyWithCompanion(ListeningSessionsCompanion data) {
    return ListeningSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastActivityAt: data.lastActivityAt.present
          ? data.lastActivityAt.value
          : this.lastActivityAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startedAt, lastActivityAt, endedAt, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.lastActivityAt == this.lastActivityAt &&
          other.endedAt == this.endedAt &&
          other.state == this.state);
}

class ListeningSessionsCompanion extends UpdateCompanion<ListeningSession> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> lastActivityAt;
  final Value<DateTime?> endedAt;
  final Value<String> state;
  final Value<int> rowid;
  const ListeningSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListeningSessionsCompanion.insert({
    required String id,
    required DateTime startedAt,
    required DateTime lastActivityAt,
    this.endedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       lastActivityAt = Value(lastActivityAt);
  static Insertable<ListeningSession> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastActivityAt,
    Expression<DateTime>? endedAt,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListeningSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? lastActivityAt,
    Value<DateTime?>? endedAt,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return ListeningSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      endedAt: endedAt ?? this.endedAt,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastActivityAt.present) {
      map['last_activity_at'] = Variable<DateTime>(lastActivityAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RatingEventsTable extends RatingEvents
    with TableInfo<$RatingEventsTable, RatingEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RatingEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    sessionId,
    rating,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rating_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<RatingEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RatingEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RatingEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $RatingEventsTable createAlias(String alias) {
    return $RatingEventsTable(attachedDatabase, alias);
  }
}

class RatingEvent extends DataClass implements Insertable<RatingEvent> {
  final String id;
  final String songId;
  final String sessionId;

  /// 1 to 10
  final int rating;
  final DateTime timestamp;
  const RatingEvent({
    required this.id,
    required this.songId,
    required this.sessionId,
    required this.rating,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['song_id'] = Variable<String>(songId);
    map['session_id'] = Variable<String>(sessionId);
    map['rating'] = Variable<int>(rating);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  RatingEventsCompanion toCompanion(bool nullToAbsent) {
    return RatingEventsCompanion(
      id: Value(id),
      songId: Value(songId),
      sessionId: Value(sessionId),
      rating: Value(rating),
      timestamp: Value(timestamp),
    );
  }

  factory RatingEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RatingEvent(
      id: serializer.fromJson<String>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      rating: serializer.fromJson<int>(json['rating']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songId': serializer.toJson<String>(songId),
      'sessionId': serializer.toJson<String>(sessionId),
      'rating': serializer.toJson<int>(rating),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  RatingEvent copyWith({
    String? id,
    String? songId,
    String? sessionId,
    int? rating,
    DateTime? timestamp,
  }) => RatingEvent(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    sessionId: sessionId ?? this.sessionId,
    rating: rating ?? this.rating,
    timestamp: timestamp ?? this.timestamp,
  );
  RatingEvent copyWithCompanion(RatingEventsCompanion data) {
    return RatingEvent(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      rating: data.rating.present ? data.rating.value : this.rating,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RatingEvent(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('sessionId: $sessionId, ')
          ..write('rating: $rating, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, sessionId, rating, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RatingEvent &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.sessionId == this.sessionId &&
          other.rating == this.rating &&
          other.timestamp == this.timestamp);
}

class RatingEventsCompanion extends UpdateCompanion<RatingEvent> {
  final Value<String> id;
  final Value<String> songId;
  final Value<String> sessionId;
  final Value<int> rating;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const RatingEventsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rating = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RatingEventsCompanion.insert({
    required String id,
    required String songId,
    required String sessionId,
    required int rating,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       songId = Value(songId),
       sessionId = Value(sessionId),
       rating = Value(rating),
       timestamp = Value(timestamp);
  static Insertable<RatingEvent> custom({
    Expression<String>? id,
    Expression<String>? songId,
    Expression<String>? sessionId,
    Expression<int>? rating,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (sessionId != null) 'session_id': sessionId,
      if (rating != null) 'rating': rating,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RatingEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? songId,
    Value<String>? sessionId,
    Value<int>? rating,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return RatingEventsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      sessionId: sessionId ?? this.sessionId,
      rating: rating ?? this.rating,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RatingEventsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('sessionId: $sessionId, ')
          ..write('rating: $rating, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackEventsTable extends PlaybackEvents
    with TableInfo<$PlaybackEventsTable, PlaybackEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondsPlayedMeta = const VerificationMeta(
    'secondsPlayed',
  );
  @override
  late final GeneratedColumn<int> secondsPlayed = GeneratedColumn<int>(
    'seconds_played',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionPercentageMeta =
      const VerificationMeta('completionPercentage');
  @override
  late final GeneratedColumn<double> completionPercentage =
      GeneratedColumn<double>(
        'completion_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    sessionId,
    eventType,
    secondsPlayed,
    completionPercentage,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('seconds_played')) {
      context.handle(
        _secondsPlayedMeta,
        secondsPlayed.isAcceptableOrUnknown(
          data['seconds_played']!,
          _secondsPlayedMeta,
        ),
      );
    }
    if (data.containsKey('completion_percentage')) {
      context.handle(
        _completionPercentageMeta,
        completionPercentage.isAcceptableOrUnknown(
          data['completion_percentage']!,
          _completionPercentageMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      secondsPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds_played'],
      ),
      completionPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}completion_percentage'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $PlaybackEventsTable createAlias(String alias) {
    return $PlaybackEventsTable(attachedDatabase, alias);
  }
}

class PlaybackEvent extends DataClass implements Insertable<PlaybackEvent> {
  final String id;
  final String songId;
  final String sessionId;

  /// 'play_start', 'completed', 'skip', 'replay', 'seek'
  final String eventType;
  final int? secondsPlayed;
  final double? completionPercentage;
  final DateTime timestamp;
  const PlaybackEvent({
    required this.id,
    required this.songId,
    required this.sessionId,
    required this.eventType,
    this.secondsPlayed,
    this.completionPercentage,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['song_id'] = Variable<String>(songId);
    map['session_id'] = Variable<String>(sessionId);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || secondsPlayed != null) {
      map['seconds_played'] = Variable<int>(secondsPlayed);
    }
    if (!nullToAbsent || completionPercentage != null) {
      map['completion_percentage'] = Variable<double>(completionPercentage);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  PlaybackEventsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackEventsCompanion(
      id: Value(id),
      songId: Value(songId),
      sessionId: Value(sessionId),
      eventType: Value(eventType),
      secondsPlayed: secondsPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(secondsPlayed),
      completionPercentage: completionPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(completionPercentage),
      timestamp: Value(timestamp),
    );
  }

  factory PlaybackEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackEvent(
      id: serializer.fromJson<String>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      secondsPlayed: serializer.fromJson<int?>(json['secondsPlayed']),
      completionPercentage: serializer.fromJson<double?>(
        json['completionPercentage'],
      ),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songId': serializer.toJson<String>(songId),
      'sessionId': serializer.toJson<String>(sessionId),
      'eventType': serializer.toJson<String>(eventType),
      'secondsPlayed': serializer.toJson<int?>(secondsPlayed),
      'completionPercentage': serializer.toJson<double?>(completionPercentage),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  PlaybackEvent copyWith({
    String? id,
    String? songId,
    String? sessionId,
    String? eventType,
    Value<int?> secondsPlayed = const Value.absent(),
    Value<double?> completionPercentage = const Value.absent(),
    DateTime? timestamp,
  }) => PlaybackEvent(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    sessionId: sessionId ?? this.sessionId,
    eventType: eventType ?? this.eventType,
    secondsPlayed: secondsPlayed.present
        ? secondsPlayed.value
        : this.secondsPlayed,
    completionPercentage: completionPercentage.present
        ? completionPercentage.value
        : this.completionPercentage,
    timestamp: timestamp ?? this.timestamp,
  );
  PlaybackEvent copyWithCompanion(PlaybackEventsCompanion data) {
    return PlaybackEvent(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      secondsPlayed: data.secondsPlayed.present
          ? data.secondsPlayed.value
          : this.secondsPlayed,
      completionPercentage: data.completionPercentage.present
          ? data.completionPercentage.value
          : this.completionPercentage,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackEvent(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('sessionId: $sessionId, ')
          ..write('eventType: $eventType, ')
          ..write('secondsPlayed: $secondsPlayed, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songId,
    sessionId,
    eventType,
    secondsPlayed,
    completionPercentage,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackEvent &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.sessionId == this.sessionId &&
          other.eventType == this.eventType &&
          other.secondsPlayed == this.secondsPlayed &&
          other.completionPercentage == this.completionPercentage &&
          other.timestamp == this.timestamp);
}

class PlaybackEventsCompanion extends UpdateCompanion<PlaybackEvent> {
  final Value<String> id;
  final Value<String> songId;
  final Value<String> sessionId;
  final Value<String> eventType;
  final Value<int?> secondsPlayed;
  final Value<double?> completionPercentage;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const PlaybackEventsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.secondsPlayed = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackEventsCompanion.insert({
    required String id,
    required String songId,
    required String sessionId,
    required String eventType,
    this.secondsPlayed = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       songId = Value(songId),
       sessionId = Value(sessionId),
       eventType = Value(eventType),
       timestamp = Value(timestamp);
  static Insertable<PlaybackEvent> custom({
    Expression<String>? id,
    Expression<String>? songId,
    Expression<String>? sessionId,
    Expression<String>? eventType,
    Expression<int>? secondsPlayed,
    Expression<double>? completionPercentage,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (sessionId != null) 'session_id': sessionId,
      if (eventType != null) 'event_type': eventType,
      if (secondsPlayed != null) 'seconds_played': secondsPlayed,
      if (completionPercentage != null)
        'completion_percentage': completionPercentage,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? songId,
    Value<String>? sessionId,
    Value<String>? eventType,
    Value<int?>? secondsPlayed,
    Value<double?>? completionPercentage,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return PlaybackEventsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      sessionId: sessionId ?? this.sessionId,
      eventType: eventType ?? this.eventType,
      secondsPlayed: secondsPlayed ?? this.secondsPlayed,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (secondsPlayed.present) {
      map['seconds_played'] = Variable<int>(secondsPlayed.value);
    }
    if (completionPercentage.present) {
      map['completion_percentage'] = Variable<double>(
        completionPercentage.value,
      );
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackEventsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('sessionId: $sessionId, ')
          ..write('eventType: $eventType, ')
          ..write('secondsPlayed: $secondsPlayed, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiscoveryCandidatesTable extends DiscoveryCandidates
    with TableInfo<$DiscoveryCandidatesTable, DiscoveryCandidate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveryCandidatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _youtubeIdMeta = const VerificationMeta(
    'youtubeId',
  );
  @override
  late final GeneratedColumn<String> youtubeId = GeneratedColumn<String>(
    'youtube_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumArtUrlMeta = const VerificationMeta(
    'albumArtUrl',
  );
  @override
  late final GeneratedColumn<String> albumArtUrl = GeneratedColumn<String>(
    'album_art_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedSongIdMeta = const VerificationMeta(
    'seedSongId',
  );
  @override
  late final GeneratedColumn<String> seedSongId = GeneratedColumn<String>(
    'seed_song_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('candidate'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastInteractedAtMeta = const VerificationMeta(
    'lastInteractedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastInteractedAt =
      GeneratedColumn<DateTime>(
        'last_interacted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    album,
    youtubeId,
    durationMs,
    albumArtUrl,
    provider,
    seedSongId,
    sessionId,
    score,
    status,
    createdAt,
    lastInteractedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovery_candidates';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveryCandidate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('youtube_id')) {
      context.handle(
        _youtubeIdMeta,
        youtubeId.isAcceptableOrUnknown(data['youtube_id']!, _youtubeIdMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('album_art_url')) {
      context.handle(
        _albumArtUrlMeta,
        albumArtUrl.isAcceptableOrUnknown(
          data['album_art_url']!,
          _albumArtUrlMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('seed_song_id')) {
      context.handle(
        _seedSongIdMeta,
        seedSongId.isAcceptableOrUnknown(
          data['seed_song_id']!,
          _seedSongIdMeta,
        ),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_interacted_at')) {
      context.handle(
        _lastInteractedAtMeta,
        lastInteractedAt.isAcceptableOrUnknown(
          data['last_interacted_at']!,
          _lastInteractedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoveryCandidate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveryCandidate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      youtubeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_id'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      albumArtUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_art_url'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      seedSongId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_song_id'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastInteractedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interacted_at'],
      ),
    );
  }

  @override
  $DiscoveryCandidatesTable createAlias(String alias) {
    return $DiscoveryCandidatesTable(attachedDatabase, alias);
  }
}

class DiscoveryCandidate extends DataClass
    implements Insertable<DiscoveryCandidate> {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? youtubeId;
  final int? durationMs;
  final String? albumArtUrl;

  /// 'lastfm', 'qloo', 'local'
  final String provider;
  final String? seedSongId;
  final String? sessionId;
  final double score;

  /// 'candidate', 'streamed', 'promoted', 'rejected'
  final String status;
  final DateTime createdAt;
  final DateTime? lastInteractedAt;
  const DiscoveryCandidate({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.youtubeId,
    this.durationMs,
    this.albumArtUrl,
    required this.provider,
    this.seedSongId,
    this.sessionId,
    required this.score,
    required this.status,
    required this.createdAt,
    this.lastInteractedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || youtubeId != null) {
      map['youtube_id'] = Variable<String>(youtubeId);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || albumArtUrl != null) {
      map['album_art_url'] = Variable<String>(albumArtUrl);
    }
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || seedSongId != null) {
      map['seed_song_id'] = Variable<String>(seedSongId);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['score'] = Variable<double>(score);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastInteractedAt != null) {
      map['last_interacted_at'] = Variable<DateTime>(lastInteractedAt);
    }
    return map;
  }

  DiscoveryCandidatesCompanion toCompanion(bool nullToAbsent) {
    return DiscoveryCandidatesCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      youtubeId: youtubeId == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeId),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      albumArtUrl: albumArtUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtUrl),
      provider: Value(provider),
      seedSongId: seedSongId == null && nullToAbsent
          ? const Value.absent()
          : Value(seedSongId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      score: Value(score),
      status: Value(status),
      createdAt: Value(createdAt),
      lastInteractedAt: lastInteractedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractedAt),
    );
  }

  factory DiscoveryCandidate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveryCandidate(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      youtubeId: serializer.fromJson<String?>(json['youtubeId']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      albumArtUrl: serializer.fromJson<String?>(json['albumArtUrl']),
      provider: serializer.fromJson<String>(json['provider']),
      seedSongId: serializer.fromJson<String?>(json['seedSongId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      score: serializer.fromJson<double>(json['score']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastInteractedAt: serializer.fromJson<DateTime?>(
        json['lastInteractedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String?>(album),
      'youtubeId': serializer.toJson<String?>(youtubeId),
      'durationMs': serializer.toJson<int?>(durationMs),
      'albumArtUrl': serializer.toJson<String?>(albumArtUrl),
      'provider': serializer.toJson<String>(provider),
      'seedSongId': serializer.toJson<String?>(seedSongId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'score': serializer.toJson<double>(score),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastInteractedAt': serializer.toJson<DateTime?>(lastInteractedAt),
    };
  }

  DiscoveryCandidate copyWith({
    String? id,
    String? title,
    String? artist,
    Value<String?> album = const Value.absent(),
    Value<String?> youtubeId = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> albumArtUrl = const Value.absent(),
    String? provider,
    Value<String?> seedSongId = const Value.absent(),
    Value<String?> sessionId = const Value.absent(),
    double? score,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> lastInteractedAt = const Value.absent(),
  }) => DiscoveryCandidate(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album.present ? album.value : this.album,
    youtubeId: youtubeId.present ? youtubeId.value : this.youtubeId,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    albumArtUrl: albumArtUrl.present ? albumArtUrl.value : this.albumArtUrl,
    provider: provider ?? this.provider,
    seedSongId: seedSongId.present ? seedSongId.value : this.seedSongId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    score: score ?? this.score,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    lastInteractedAt: lastInteractedAt.present
        ? lastInteractedAt.value
        : this.lastInteractedAt,
  );
  DiscoveryCandidate copyWithCompanion(DiscoveryCandidatesCompanion data) {
    return DiscoveryCandidate(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      youtubeId: data.youtubeId.present ? data.youtubeId.value : this.youtubeId,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      albumArtUrl: data.albumArtUrl.present
          ? data.albumArtUrl.value
          : this.albumArtUrl,
      provider: data.provider.present ? data.provider.value : this.provider,
      seedSongId: data.seedSongId.present
          ? data.seedSongId.value
          : this.seedSongId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      score: data.score.present ? data.score.value : this.score,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastInteractedAt: data.lastInteractedAt.present
          ? data.lastInteractedAt.value
          : this.lastInteractedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryCandidate(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('durationMs: $durationMs, ')
          ..write('albumArtUrl: $albumArtUrl, ')
          ..write('provider: $provider, ')
          ..write('seedSongId: $seedSongId, ')
          ..write('sessionId: $sessionId, ')
          ..write('score: $score, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastInteractedAt: $lastInteractedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    youtubeId,
    durationMs,
    albumArtUrl,
    provider,
    seedSongId,
    sessionId,
    score,
    status,
    createdAt,
    lastInteractedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveryCandidate &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.youtubeId == this.youtubeId &&
          other.durationMs == this.durationMs &&
          other.albumArtUrl == this.albumArtUrl &&
          other.provider == this.provider &&
          other.seedSongId == this.seedSongId &&
          other.sessionId == this.sessionId &&
          other.score == this.score &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.lastInteractedAt == this.lastInteractedAt);
}

class DiscoveryCandidatesCompanion extends UpdateCompanion<DiscoveryCandidate> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<String?> album;
  final Value<String?> youtubeId;
  final Value<int?> durationMs;
  final Value<String?> albumArtUrl;
  final Value<String> provider;
  final Value<String?> seedSongId;
  final Value<String?> sessionId;
  final Value<double> score;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastInteractedAt;
  final Value<int> rowid;
  const DiscoveryCandidatesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.youtubeId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.albumArtUrl = const Value.absent(),
    this.provider = const Value.absent(),
    this.seedSongId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.score = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastInteractedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscoveryCandidatesCompanion.insert({
    required String id,
    required String title,
    required String artist,
    this.album = const Value.absent(),
    this.youtubeId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.albumArtUrl = const Value.absent(),
    required String provider,
    this.seedSongId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.score = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.lastInteractedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artist = Value(artist),
       provider = Value(provider),
       createdAt = Value(createdAt);
  static Insertable<DiscoveryCandidate> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? youtubeId,
    Expression<int>? durationMs,
    Expression<String>? albumArtUrl,
    Expression<String>? provider,
    Expression<String>? seedSongId,
    Expression<String>? sessionId,
    Expression<double>? score,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastInteractedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (youtubeId != null) 'youtube_id': youtubeId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (albumArtUrl != null) 'album_art_url': albumArtUrl,
      if (provider != null) 'provider': provider,
      if (seedSongId != null) 'seed_song_id': seedSongId,
      if (sessionId != null) 'session_id': sessionId,
      if (score != null) 'score': score,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (lastInteractedAt != null) 'last_interacted_at': lastInteractedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscoveryCandidatesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<String?>? album,
    Value<String?>? youtubeId,
    Value<int?>? durationMs,
    Value<String?>? albumArtUrl,
    Value<String>? provider,
    Value<String?>? seedSongId,
    Value<String?>? sessionId,
    Value<double>? score,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastInteractedAt,
    Value<int>? rowid,
  }) {
    return DiscoveryCandidatesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      youtubeId: youtubeId ?? this.youtubeId,
      durationMs: durationMs ?? this.durationMs,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      provider: provider ?? this.provider,
      seedSongId: seedSongId ?? this.seedSongId,
      sessionId: sessionId ?? this.sessionId,
      score: score ?? this.score,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastInteractedAt: lastInteractedAt ?? this.lastInteractedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (youtubeId.present) {
      map['youtube_id'] = Variable<String>(youtubeId.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (albumArtUrl.present) {
      map['album_art_url'] = Variable<String>(albumArtUrl.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (seedSongId.present) {
      map['seed_song_id'] = Variable<String>(seedSongId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastInteractedAt.present) {
      map['last_interacted_at'] = Variable<DateTime>(lastInteractedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryCandidatesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('durationMs: $durationMs, ')
          ..write('albumArtUrl: $albumArtUrl, ')
          ..write('provider: $provider, ')
          ..write('seedSongId: $seedSongId, ')
          ..write('sessionId: $sessionId, ')
          ..write('score: $score, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastInteractedAt: $lastInteractedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $LyricsTableTable lyricsTable = $LyricsTableTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $ListeningSessionsTable listeningSessions =
      $ListeningSessionsTable(this);
  late final $RatingEventsTable ratingEvents = $RatingEventsTable(this);
  late final $PlaybackEventsTable playbackEvents = $PlaybackEventsTable(this);
  late final $DiscoveryCandidatesTable discoveryCandidates =
      $DiscoveryCandidatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songs,
    lyricsTable,
    playlists,
    playlistSongs,
    listeningSessions,
    ratingEvents,
    playbackEvents,
    discoveryCandidates,
  ];
}

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      required String id,
      Value<String?> filename,
      required String title,
      Value<String> artist,
      Value<String?> album,
      Value<String?> youtubeId,
      Value<String?> localPath,
      Value<String> status,
      Value<int?> durationMs,
      Value<String?> albumArtUrl,
      Value<String?> albumArtPath,
      Value<bool> artEmbedded,
      Value<String?> trackUri,
      Value<String?> isrc,
      Value<int?> trackNumber,
      Value<bool> explicit,
      Value<int?> popularity,
      Value<String?> genres,
      Value<double?> danceability,
      Value<double?> energy,
      Value<int?> key,
      Value<double?> loudness,
      Value<int?> mode,
      Value<double?> speechiness,
      Value<double?> acousticness,
      Value<double?> instrumentalness,
      Value<double?> liveness,
      Value<double?> valence,
      Value<double?> tempo,
      Value<int?> timeSignature,
      Value<DateTime?> addedAt,
      Value<int?> sleepOrder,
      Value<int?> noSleepOrder,
      Value<DateTime?> lastPlayedAt,
      Value<int> playCount,
      Value<DateTime?> likedAt,
      Value<String?> resolvedYtTitle,
      Value<String?> error,
      Value<int> rowid,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<String> id,
      Value<String?> filename,
      Value<String> title,
      Value<String> artist,
      Value<String?> album,
      Value<String?> youtubeId,
      Value<String?> localPath,
      Value<String> status,
      Value<int?> durationMs,
      Value<String?> albumArtUrl,
      Value<String?> albumArtPath,
      Value<bool> artEmbedded,
      Value<String?> trackUri,
      Value<String?> isrc,
      Value<int?> trackNumber,
      Value<bool> explicit,
      Value<int?> popularity,
      Value<String?> genres,
      Value<double?> danceability,
      Value<double?> energy,
      Value<int?> key,
      Value<double?> loudness,
      Value<int?> mode,
      Value<double?> speechiness,
      Value<double?> acousticness,
      Value<double?> instrumentalness,
      Value<double?> liveness,
      Value<double?> valence,
      Value<double?> tempo,
      Value<int?> timeSignature,
      Value<DateTime?> addedAt,
      Value<int?> sleepOrder,
      Value<int?> noSleepOrder,
      Value<DateTime?> lastPlayedAt,
      Value<int> playCount,
      Value<DateTime?> likedAt,
      Value<String?> resolvedYtTitle,
      Value<String?> error,
      Value<int> rowid,
    });

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeId => $composableBuilder(
    column: $table.youtubeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtUrl => $composableBuilder(
    column: $table.albumArtUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtPath => $composableBuilder(
    column: $table.albumArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get artEmbedded => $composableBuilder(
    column: $table.artEmbedded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackUri => $composableBuilder(
    column: $table.trackUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loudness => $composableBuilder(
    column: $table.loudness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speechiness => $composableBuilder(
    column: $table.speechiness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get instrumentalness => $composableBuilder(
    column: $table.instrumentalness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get liveness => $composableBuilder(
    column: $table.liveness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSignature => $composableBuilder(
    column: $table.timeSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepOrder => $composableBuilder(
    column: $table.sleepOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noSleepOrder => $composableBuilder(
    column: $table.noSleepOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedYtTitle => $composableBuilder(
    column: $table.resolvedYtTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeId => $composableBuilder(
    column: $table.youtubeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtUrl => $composableBuilder(
    column: $table.albumArtUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtPath => $composableBuilder(
    column: $table.albumArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get artEmbedded => $composableBuilder(
    column: $table.artEmbedded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackUri => $composableBuilder(
    column: $table.trackUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loudness => $composableBuilder(
    column: $table.loudness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speechiness => $composableBuilder(
    column: $table.speechiness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get instrumentalness => $composableBuilder(
    column: $table.instrumentalness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get liveness => $composableBuilder(
    column: $table.liveness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSignature => $composableBuilder(
    column: $table.timeSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepOrder => $composableBuilder(
    column: $table.sleepOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noSleepOrder => $composableBuilder(
    column: $table.noSleepOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedYtTitle => $composableBuilder(
    column: $table.resolvedYtTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get youtubeId =>
      $composableBuilder(column: $table.youtubeId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumArtUrl => $composableBuilder(
    column: $table.albumArtUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumArtPath => $composableBuilder(
    column: $table.albumArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get artEmbedded => $composableBuilder(
    column: $table.artEmbedded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackUri =>
      $composableBuilder(column: $table.trackUri, builder: (column) => column);

  GeneratedColumn<String> get isrc =>
      $composableBuilder(column: $table.isrc, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  GeneratedColumn<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<double> get loudness =>
      $composableBuilder(column: $table.loudness, builder: (column) => column);

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get speechiness => $composableBuilder(
    column: $table.speechiness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get instrumentalness => $composableBuilder(
    column: $table.instrumentalness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get liveness =>
      $composableBuilder(column: $table.liveness, builder: (column) => column);

  GeneratedColumn<double> get valence =>
      $composableBuilder(column: $table.valence, builder: (column) => column);

  GeneratedColumn<double> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<int> get timeSignature => $composableBuilder(
    column: $table.timeSignature,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get sleepOrder => $composableBuilder(
    column: $table.sleepOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get noSleepOrder => $composableBuilder(
    column: $table.noSleepOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get likedAt =>
      $composableBuilder(column: $table.likedAt, builder: (column) => column);

  GeneratedColumn<String> get resolvedYtTitle => $composableBuilder(
    column: $table.resolvedYtTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          SongRow,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (SongRow, BaseReferences<_$AppDatabase, $SongsTable, SongRow>),
          SongRow,
          PrefetchHooks Function()
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> filename = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> youtubeId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> albumArtUrl = const Value.absent(),
                Value<String?> albumArtPath = const Value.absent(),
                Value<bool> artEmbedded = const Value.absent(),
                Value<String?> trackUri = const Value.absent(),
                Value<String?> isrc = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int?> popularity = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<double?> danceability = const Value.absent(),
                Value<double?> energy = const Value.absent(),
                Value<int?> key = const Value.absent(),
                Value<double?> loudness = const Value.absent(),
                Value<int?> mode = const Value.absent(),
                Value<double?> speechiness = const Value.absent(),
                Value<double?> acousticness = const Value.absent(),
                Value<double?> instrumentalness = const Value.absent(),
                Value<double?> liveness = const Value.absent(),
                Value<double?> valence = const Value.absent(),
                Value<double?> tempo = const Value.absent(),
                Value<int?> timeSignature = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int?> sleepOrder = const Value.absent(),
                Value<int?> noSleepOrder = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> likedAt = const Value.absent(),
                Value<String?> resolvedYtTitle = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                filename: filename,
                title: title,
                artist: artist,
                album: album,
                youtubeId: youtubeId,
                localPath: localPath,
                status: status,
                durationMs: durationMs,
                albumArtUrl: albumArtUrl,
                albumArtPath: albumArtPath,
                artEmbedded: artEmbedded,
                trackUri: trackUri,
                isrc: isrc,
                trackNumber: trackNumber,
                explicit: explicit,
                popularity: popularity,
                genres: genres,
                danceability: danceability,
                energy: energy,
                key: key,
                loudness: loudness,
                mode: mode,
                speechiness: speechiness,
                acousticness: acousticness,
                instrumentalness: instrumentalness,
                liveness: liveness,
                valence: valence,
                tempo: tempo,
                timeSignature: timeSignature,
                addedAt: addedAt,
                sleepOrder: sleepOrder,
                noSleepOrder: noSleepOrder,
                lastPlayedAt: lastPlayedAt,
                playCount: playCount,
                likedAt: likedAt,
                resolvedYtTitle: resolvedYtTitle,
                error: error,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> filename = const Value.absent(),
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> youtubeId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> albumArtUrl = const Value.absent(),
                Value<String?> albumArtPath = const Value.absent(),
                Value<bool> artEmbedded = const Value.absent(),
                Value<String?> trackUri = const Value.absent(),
                Value<String?> isrc = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int?> popularity = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<double?> danceability = const Value.absent(),
                Value<double?> energy = const Value.absent(),
                Value<int?> key = const Value.absent(),
                Value<double?> loudness = const Value.absent(),
                Value<int?> mode = const Value.absent(),
                Value<double?> speechiness = const Value.absent(),
                Value<double?> acousticness = const Value.absent(),
                Value<double?> instrumentalness = const Value.absent(),
                Value<double?> liveness = const Value.absent(),
                Value<double?> valence = const Value.absent(),
                Value<double?> tempo = const Value.absent(),
                Value<int?> timeSignature = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int?> sleepOrder = const Value.absent(),
                Value<int?> noSleepOrder = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> likedAt = const Value.absent(),
                Value<String?> resolvedYtTitle = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                filename: filename,
                title: title,
                artist: artist,
                album: album,
                youtubeId: youtubeId,
                localPath: localPath,
                status: status,
                durationMs: durationMs,
                albumArtUrl: albumArtUrl,
                albumArtPath: albumArtPath,
                artEmbedded: artEmbedded,
                trackUri: trackUri,
                isrc: isrc,
                trackNumber: trackNumber,
                explicit: explicit,
                popularity: popularity,
                genres: genres,
                danceability: danceability,
                energy: energy,
                key: key,
                loudness: loudness,
                mode: mode,
                speechiness: speechiness,
                acousticness: acousticness,
                instrumentalness: instrumentalness,
                liveness: liveness,
                valence: valence,
                tempo: tempo,
                timeSignature: timeSignature,
                addedAt: addedAt,
                sleepOrder: sleepOrder,
                noSleepOrder: noSleepOrder,
                lastPlayedAt: lastPlayedAt,
                playCount: playCount,
                likedAt: likedAt,
                resolvedYtTitle: resolvedYtTitle,
                error: error,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      SongRow,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (SongRow, BaseReferences<_$AppDatabase, $SongsTable, SongRow>),
      SongRow,
      PrefetchHooks Function()
    >;
typedef $$LyricsTableTableCreateCompanionBuilder =
    LyricsTableCompanion Function({
      required String songId,
      required String type,
      required String content,
      Value<int> rowid,
    });
typedef $$LyricsTableTableUpdateCompanionBuilder =
    LyricsTableCompanion Function({
      Value<String> songId,
      Value<String> type,
      Value<String> content,
      Value<int> rowid,
    });

class $$LyricsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LyricsTableTable> {
  $$LyricsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LyricsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricsTableTable> {
  $$LyricsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LyricsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricsTableTable> {
  $$LyricsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$LyricsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricsTableTable,
          LyricsTableData,
          $$LyricsTableTableFilterComposer,
          $$LyricsTableTableOrderingComposer,
          $$LyricsTableTableAnnotationComposer,
          $$LyricsTableTableCreateCompanionBuilder,
          $$LyricsTableTableUpdateCompanionBuilder,
          (
            LyricsTableData,
            BaseReferences<_$AppDatabase, $LyricsTableTable, LyricsTableData>,
          ),
          LyricsTableData,
          PrefetchHooks Function()
        > {
  $$LyricsTableTableTableManager(_$AppDatabase db, $LyricsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsTableCompanion(
                songId: songId,
                type: type,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required String type,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => LyricsTableCompanion.insert(
                songId: songId,
                type: type,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LyricsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricsTableTable,
      LyricsTableData,
      $$LyricsTableTableFilterComposer,
      $$LyricsTableTableOrderingComposer,
      $$LyricsTableTableAnnotationComposer,
      $$LyricsTableTableCreateCompanionBuilder,
      $$LyricsTableTableUpdateCompanionBuilder,
      (
        LyricsTableData,
        BaseReferences<_$AppDatabase, $LyricsTableTable, LyricsTableData>,
      ),
      LyricsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
          Playlist,
          PrefetchHooks Function()
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
      Playlist,
      PrefetchHooks Function()
    >;
typedef $$PlaylistSongsTableCreateCompanionBuilder =
    PlaylistSongsCompanion Function({
      required String playlistId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaylistSongsTableUpdateCompanionBuilder =
    PlaylistSongsCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

class $$PlaylistSongsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$PlaylistSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongsTable,
          PlaylistSong,
          $$PlaylistSongsTableFilterComposer,
          $$PlaylistSongsTableOrderingComposer,
          $$PlaylistSongsTableAnnotationComposer,
          $$PlaylistSongsTableCreateCompanionBuilder,
          $$PlaylistSongsTableUpdateCompanionBuilder,
          (
            PlaylistSong,
            BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSong>,
          ),
          PlaylistSong,
          PrefetchHooks Function()
        > {
  $$PlaylistSongsTableTableManager(_$AppDatabase db, $PlaylistSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsCompanion(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongsTable,
      PlaylistSong,
      $$PlaylistSongsTableFilterComposer,
      $$PlaylistSongsTableOrderingComposer,
      $$PlaylistSongsTableAnnotationComposer,
      $$PlaylistSongsTableCreateCompanionBuilder,
      $$PlaylistSongsTableUpdateCompanionBuilder,
      (
        PlaylistSong,
        BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSong>,
      ),
      PlaylistSong,
      PrefetchHooks Function()
    >;
typedef $$ListeningSessionsTableCreateCompanionBuilder =
    ListeningSessionsCompanion Function({
      required String id,
      required DateTime startedAt,
      required DateTime lastActivityAt,
      Value<DateTime?> endedAt,
      Value<String> state,
      Value<int> rowid,
    });
typedef $$ListeningSessionsTableUpdateCompanionBuilder =
    ListeningSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime> lastActivityAt,
      Value<DateTime?> endedAt,
      Value<String> state,
      Value<int> rowid,
    });

class $$ListeningSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningSessionsTable> {
  $$ListeningSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListeningSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningSessionsTable> {
  $$ListeningSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListeningSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningSessionsTable> {
  $$ListeningSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$ListeningSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListeningSessionsTable,
          ListeningSession,
          $$ListeningSessionsTableFilterComposer,
          $$ListeningSessionsTableOrderingComposer,
          $$ListeningSessionsTableAnnotationComposer,
          $$ListeningSessionsTableCreateCompanionBuilder,
          $$ListeningSessionsTableUpdateCompanionBuilder,
          (
            ListeningSession,
            BaseReferences<
              _$AppDatabase,
              $ListeningSessionsTable,
              ListeningSession
            >,
          ),
          ListeningSession,
          PrefetchHooks Function()
        > {
  $$ListeningSessionsTableTableManager(
    _$AppDatabase db,
    $ListeningSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeningSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> lastActivityAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeningSessionsCompanion(
                id: id,
                startedAt: startedAt,
                lastActivityAt: lastActivityAt,
                endedAt: endedAt,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                required DateTime lastActivityAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeningSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                lastActivityAt: lastActivityAt,
                endedAt: endedAt,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListeningSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListeningSessionsTable,
      ListeningSession,
      $$ListeningSessionsTableFilterComposer,
      $$ListeningSessionsTableOrderingComposer,
      $$ListeningSessionsTableAnnotationComposer,
      $$ListeningSessionsTableCreateCompanionBuilder,
      $$ListeningSessionsTableUpdateCompanionBuilder,
      (
        ListeningSession,
        BaseReferences<
          _$AppDatabase,
          $ListeningSessionsTable,
          ListeningSession
        >,
      ),
      ListeningSession,
      PrefetchHooks Function()
    >;
typedef $$RatingEventsTableCreateCompanionBuilder =
    RatingEventsCompanion Function({
      required String id,
      required String songId,
      required String sessionId,
      required int rating,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$RatingEventsTableUpdateCompanionBuilder =
    RatingEventsCompanion Function({
      Value<String> id,
      Value<String> songId,
      Value<String> sessionId,
      Value<int> rating,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$RatingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $RatingEventsTable> {
  $$RatingEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RatingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $RatingEventsTable> {
  $$RatingEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RatingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RatingEventsTable> {
  $$RatingEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$RatingEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RatingEventsTable,
          RatingEvent,
          $$RatingEventsTableFilterComposer,
          $$RatingEventsTableOrderingComposer,
          $$RatingEventsTableAnnotationComposer,
          $$RatingEventsTableCreateCompanionBuilder,
          $$RatingEventsTableUpdateCompanionBuilder,
          (
            RatingEvent,
            BaseReferences<_$AppDatabase, $RatingEventsTable, RatingEvent>,
          ),
          RatingEvent,
          PrefetchHooks Function()
        > {
  $$RatingEventsTableTableManager(_$AppDatabase db, $RatingEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RatingEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RatingEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RatingEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatingEventsCompanion(
                id: id,
                songId: songId,
                sessionId: sessionId,
                rating: rating,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String songId,
                required String sessionId,
                required int rating,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => RatingEventsCompanion.insert(
                id: id,
                songId: songId,
                sessionId: sessionId,
                rating: rating,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RatingEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RatingEventsTable,
      RatingEvent,
      $$RatingEventsTableFilterComposer,
      $$RatingEventsTableOrderingComposer,
      $$RatingEventsTableAnnotationComposer,
      $$RatingEventsTableCreateCompanionBuilder,
      $$RatingEventsTableUpdateCompanionBuilder,
      (
        RatingEvent,
        BaseReferences<_$AppDatabase, $RatingEventsTable, RatingEvent>,
      ),
      RatingEvent,
      PrefetchHooks Function()
    >;
typedef $$PlaybackEventsTableCreateCompanionBuilder =
    PlaybackEventsCompanion Function({
      required String id,
      required String songId,
      required String sessionId,
      required String eventType,
      Value<int?> secondsPlayed,
      Value<double?> completionPercentage,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$PlaybackEventsTableUpdateCompanionBuilder =
    PlaybackEventsCompanion Function({
      Value<String> id,
      Value<String> songId,
      Value<String> sessionId,
      Value<String> eventType,
      Value<int?> secondsPlayed,
      Value<double?> completionPercentage,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$PlaybackEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackEventsTable> {
  $$PlaybackEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondsPlayed => $composableBuilder(
    column: $table.secondsPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackEventsTable> {
  $$PlaybackEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondsPlayed => $composableBuilder(
    column: $table.secondsPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackEventsTable> {
  $$PlaybackEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get secondsPlayed => $composableBuilder(
    column: $table.secondsPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$PlaybackEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackEventsTable,
          PlaybackEvent,
          $$PlaybackEventsTableFilterComposer,
          $$PlaybackEventsTableOrderingComposer,
          $$PlaybackEventsTableAnnotationComposer,
          $$PlaybackEventsTableCreateCompanionBuilder,
          $$PlaybackEventsTableUpdateCompanionBuilder,
          (
            PlaybackEvent,
            BaseReferences<_$AppDatabase, $PlaybackEventsTable, PlaybackEvent>,
          ),
          PlaybackEvent,
          PrefetchHooks Function()
        > {
  $$PlaybackEventsTableTableManager(
    _$AppDatabase db,
    $PlaybackEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int?> secondsPlayed = const Value.absent(),
                Value<double?> completionPercentage = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackEventsCompanion(
                id: id,
                songId: songId,
                sessionId: sessionId,
                eventType: eventType,
                secondsPlayed: secondsPlayed,
                completionPercentage: completionPercentage,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String songId,
                required String sessionId,
                required String eventType,
                Value<int?> secondsPlayed = const Value.absent(),
                Value<double?> completionPercentage = const Value.absent(),
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => PlaybackEventsCompanion.insert(
                id: id,
                songId: songId,
                sessionId: sessionId,
                eventType: eventType,
                secondsPlayed: secondsPlayed,
                completionPercentage: completionPercentage,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackEventsTable,
      PlaybackEvent,
      $$PlaybackEventsTableFilterComposer,
      $$PlaybackEventsTableOrderingComposer,
      $$PlaybackEventsTableAnnotationComposer,
      $$PlaybackEventsTableCreateCompanionBuilder,
      $$PlaybackEventsTableUpdateCompanionBuilder,
      (
        PlaybackEvent,
        BaseReferences<_$AppDatabase, $PlaybackEventsTable, PlaybackEvent>,
      ),
      PlaybackEvent,
      PrefetchHooks Function()
    >;
typedef $$DiscoveryCandidatesTableCreateCompanionBuilder =
    DiscoveryCandidatesCompanion Function({
      required String id,
      required String title,
      required String artist,
      Value<String?> album,
      Value<String?> youtubeId,
      Value<int?> durationMs,
      Value<String?> albumArtUrl,
      required String provider,
      Value<String?> seedSongId,
      Value<String?> sessionId,
      Value<double> score,
      Value<String> status,
      required DateTime createdAt,
      Value<DateTime?> lastInteractedAt,
      Value<int> rowid,
    });
typedef $$DiscoveryCandidatesTableUpdateCompanionBuilder =
    DiscoveryCandidatesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artist,
      Value<String?> album,
      Value<String?> youtubeId,
      Value<int?> durationMs,
      Value<String?> albumArtUrl,
      Value<String> provider,
      Value<String?> seedSongId,
      Value<String?> sessionId,
      Value<double> score,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> lastInteractedAt,
      Value<int> rowid,
    });

class $$DiscoveryCandidatesTableFilterComposer
    extends Composer<_$AppDatabase, $DiscoveryCandidatesTable> {
  $$DiscoveryCandidatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeId => $composableBuilder(
    column: $table.youtubeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtUrl => $composableBuilder(
    column: $table.albumArtUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seedSongId => $composableBuilder(
    column: $table.seedSongId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiscoveryCandidatesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiscoveryCandidatesTable> {
  $$DiscoveryCandidatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeId => $composableBuilder(
    column: $table.youtubeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtUrl => $composableBuilder(
    column: $table.albumArtUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seedSongId => $composableBuilder(
    column: $table.seedSongId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscoveryCandidatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiscoveryCandidatesTable> {
  $$DiscoveryCandidatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get youtubeId =>
      $composableBuilder(column: $table.youtubeId, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumArtUrl => $composableBuilder(
    column: $table.albumArtUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get seedSongId => $composableBuilder(
    column: $table.seedSongId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => column,
  );
}

class $$DiscoveryCandidatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiscoveryCandidatesTable,
          DiscoveryCandidate,
          $$DiscoveryCandidatesTableFilterComposer,
          $$DiscoveryCandidatesTableOrderingComposer,
          $$DiscoveryCandidatesTableAnnotationComposer,
          $$DiscoveryCandidatesTableCreateCompanionBuilder,
          $$DiscoveryCandidatesTableUpdateCompanionBuilder,
          (
            DiscoveryCandidate,
            BaseReferences<
              _$AppDatabase,
              $DiscoveryCandidatesTable,
              DiscoveryCandidate
            >,
          ),
          DiscoveryCandidate,
          PrefetchHooks Function()
        > {
  $$DiscoveryCandidatesTableTableManager(
    _$AppDatabase db,
    $DiscoveryCandidatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveryCandidatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveryCandidatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DiscoveryCandidatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> youtubeId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> albumArtUrl = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String?> seedSongId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastInteractedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscoveryCandidatesCompanion(
                id: id,
                title: title,
                artist: artist,
                album: album,
                youtubeId: youtubeId,
                durationMs: durationMs,
                albumArtUrl: albumArtUrl,
                provider: provider,
                seedSongId: seedSongId,
                sessionId: sessionId,
                score: score,
                status: status,
                createdAt: createdAt,
                lastInteractedAt: lastInteractedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artist,
                Value<String?> album = const Value.absent(),
                Value<String?> youtubeId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> albumArtUrl = const Value.absent(),
                required String provider,
                Value<String?> seedSongId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastInteractedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscoveryCandidatesCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                album: album,
                youtubeId: youtubeId,
                durationMs: durationMs,
                albumArtUrl: albumArtUrl,
                provider: provider,
                seedSongId: seedSongId,
                sessionId: sessionId,
                score: score,
                status: status,
                createdAt: createdAt,
                lastInteractedAt: lastInteractedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiscoveryCandidatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiscoveryCandidatesTable,
      DiscoveryCandidate,
      $$DiscoveryCandidatesTableFilterComposer,
      $$DiscoveryCandidatesTableOrderingComposer,
      $$DiscoveryCandidatesTableAnnotationComposer,
      $$DiscoveryCandidatesTableCreateCompanionBuilder,
      $$DiscoveryCandidatesTableUpdateCompanionBuilder,
      (
        DiscoveryCandidate,
        BaseReferences<
          _$AppDatabase,
          $DiscoveryCandidatesTable,
          DiscoveryCandidate
        >,
      ),
      DiscoveryCandidate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$LyricsTableTableTableManager get lyricsTable =>
      $$LyricsTableTableTableManager(_db, _db.lyricsTable);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistSongsTableTableManager get playlistSongs =>
      $$PlaylistSongsTableTableManager(_db, _db.playlistSongs);
  $$ListeningSessionsTableTableManager get listeningSessions =>
      $$ListeningSessionsTableTableManager(_db, _db.listeningSessions);
  $$RatingEventsTableTableManager get ratingEvents =>
      $$RatingEventsTableTableManager(_db, _db.ratingEvents);
  $$PlaybackEventsTableTableManager get playbackEvents =>
      $$PlaybackEventsTableTableManager(_db, _db.playbackEvents);
  $$DiscoveryCandidatesTableTableManager get discoveryCandidates =>
      $$DiscoveryCandidatesTableTableManager(_db, _db.discoveryCandidates);
}
