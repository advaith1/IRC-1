class Music
  include Cinch::Plugin

  match /spalbum (.+)/, method: :spotifyalbum
  match /spartist (.+)/, method: :spotifyartist
  timer 3600, method: :updatespotify
  match /spotifyapi/, method: :checkperms
  match /spotify (.+)/, method: :spotifytrack
  match /lastfm (.+)/, method: :lastfmtrack
  match /lastfmartist (.+)/, method: :lastfmtopartist
  match /ltar (.+)/, method: :lastfmtopartist
  match /lastfmart (.+)/, method: :lastfmartist
  match /lastfmalbum (.+)/, method: :lastfmalbum
  match /ltal (.+)/, method: :lastfmalbum
  match /lastfmtracks (.+)/, method: :lastfmtoptracks
  match /ltop (.+)/, method: :lastfmtoptracks
  match /lastfmcompare (.+) (.+)/, method: :lastcompare

  def lastfmalbum(m, user)
    if CONFIG['lastfm'].nil? || CONFIG['lastfm'] == ''
      m.reply 'This command requires an API key from last.fm!'
      return
    end
    parse = JSON.parse(RestClient.get("http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&period=overall&limit=3&user=#{user}&api_key=#{CONFIG['lastfm']}&format=json"))

    base = parse['topalbums']['album']

    user = parse['topalbums']['@attr']['user']

    amount = base.length

    if amount.zero?
      m.reply 'User has no top albums!'
      return
    end
    m.reply "Top 3 Albums for #{user}"
    if amount.positive?
      sleep 1
      art1name = base[0]['name']
      art1scrob = base[0]['playcount']
      m.reply "1st: #{Format(:bold, art1name)} with #{Format(:bold, art1scrob)} scrobbles."
    end
    if amount > 1
      sleep 1
      art2name = base[1]['name']
      art2scrob = base[1]['playcount']
      m.reply "2nd: #{Format(:bold, art2name)} with #{Format(:bold, art2scrob)} scrobbles."
    end
    if amount > 2
      sleep 1
      art3name = base[2]['name']
      art3scrob = base[2]['playcount']
      m.reply "3rd: #{Format(:bold, art3name)} with #{Format(:bold, art3scrob)} scrobbles."
    end
    sleep 1
    m.reply "View more: http://www.last.fm/user/#{user}/library/albums?date_preset=ALL_TIME"
  end

  def lastcompare(m, user1, user2)
    if CONFIG['lastfm'].nil? || CONFIG['lastfm'] == ''
      m.reply 'This command requires an API key from last.fm!'
      return
    end
    lastfmtrack(m, user1)
    sleep 1
    lastfmtrack(m, user2)
  end

  def lastfmtoptracks(m, user)
    if CONFIG['lastfm'].nil? || CONFIG['lastfm'] == ''
      m.reply 'This command requires an API key from last.fm!'
      return
    end
    parse = JSON.parse(RestClient.get("http://ws.audioscrobbler.com/2.0/?method=user.gettoptracks&period=overall&limit=3&user=#{user}&api_key=#{CONFIG['lastfm']}&format=json"))

    base = parse['toptracks']['track']

    user = parse['toptracks']['@attr']['user']

    amount = base.length

    if amount.zero?
      m.reply 'User has no top tracks!'
      return
    end
    m.reply "Top 3 Tracks for #{user}"
    if amount.positive?
      sleep 1
      art1name = base[0]['name']
      art1scrob = base[0]['playcount']
      m.reply "1st: #{Format(:bold, art1name)} with #{Format(:bold, art1scrob)} scrobbles."
    end
    if amount > 1
      sleep 1
      art2name = base[1]['name']
      art2scrob = base[1]['playcount']
      m.reply "2nd: #{Format(:bold, art2name)} with #{Format(:bold, art2scrob)} scrobbles."
    end
    if amount > 2
      sleep 1
      art3name = base[2]['name']
      art3scrob = base[2]['playcount']
      m.reply "3rd: #{Format(:bold, art3name)} with #{Format(:bold, art3scrob)} scrobbles."
    end
    sleep 1
    m.reply "View more: http://www.last.fm/user/#{user}/library/tracks?date_preset=ALL_TIME"
  end

  def lastfmtopartist(m, user)
    if CONFIG['lastfm'].nil? || CONFIG['lastfm'] == ''
      m.reply 'This command requires an API key from last.fm!'
      return
    end
    parse = JSON.parse(RestClient.get("http://ws.audioscrobbler.com/2.0/?method=user.gettopartists&period=overall&limit=3&user=#{user}&api_key=#{CONFIG['lastfm']}&format=json"))

    base = parse['topartists']['artist']

    user = parse['topartists']['@attr']['user']

    amount = base.length

    if amount.zero?
      m.reply 'User has no top artists!'
      return
    end
    m.reply "Top 3 Artists for #{user}"
    if amount.positive?
      sleep 1
      art1name = base[0]['name']
      art1scrob = base[0]['playcount']
      m.reply "1st: #{Format(:bold, art1name)} with #{Format(:bold, art1scrob)} scrobbles."
    end
    if amount > 1
      sleep 1
      art2name = base[1]['name']
      art2scrob = base[1]['playcount']
      m.reply "2nd: #{Format(:bold, art2name)} with #{Format(:bold, art2scrob)} scrobbles."
    end
    if amount > 2
      sleep 1
      art3name = base[2]['name']
      art3scrob = base[2]['playcount']
      m.reply "3rd: #{Format(:bold, art3name)} with #{Format(:bold, art3scrob)} scrobbles."
    end
    sleep 1
    m.reply "View more: http://www.last.fm/user/#{user}/library/artists?date_preset=ALL_TIME"
  end

  def lastfmtrack(m, user)
    if CONFIG['lastfm'].nil? || CONFIG['lastfm'] == ''
      m.reply 'This command requires an API key from last.fm!'
      return
    end
    parse = JSON.parse(RestClient.get("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&limit=1&user=#{user}&api_key=#{CONFIG['lastfm']}&format=json"))

    base = parse['recenttracks']['track'][0]

    user = parse['recenttracks']['@attr']['user']

    artist = base['artist']['#text']
    track = base['name']
    album = base['album']['#text']

    begin
      np = base['@attr']['nowplaying']
      timeago = np
      playing = true
    rescue
      np = base['date']['uts']
      t = Time.now.to_i - np.to_i
      mm, ss = t.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      timeago = format('%d days, %d hours, %d minutes and %d seconds', dd, hh, mm, ss)
      playing = false
    end

    if playing
      m.reply "#{Format(:bold, user)} is currently listening to #{Format(:bold, track)} by #{Format(:bold, artist)} found in the album #{Format(:bold, album)}."
    else
      m.reply "#{Format(:bold, user)} last listened to #{Format(:bold, track)} by #{Format(:bold, artist)} found in the album #{Format(:bold, album)} about #{Format(:bold, timeago)} ago."
    end
  end

  def checkspotifykey
    return 'no-key' if CONFIG['spotify'].nil? || CONFIG['spotify'] == ''
    return 'missing-client' if CONFIG['spotifyclientid'].nil? || CONFIG['spotifyclientid'] == '' || CONFIG['spotifysecret'].nil? || CONFIG['spotifysecret'] == ''
    true
  end

  def spotifytrack(m, song)
    unless checkspotifykey == true
      updatekey if checkspotifykey == 'no-key'
      if checkspotifykey == 'missing-client' || checkspotifykey == 'no-key'
        m.reply 'Missing Spotify Client Credentials! MSCC!!'
        return
      end
    end
    uri = URI.parse("https://api.spotify.com/v1/search?q=#{song}&type=track&market=US&limit=1")
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{CONFIG['spotify']}"

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    parse = JSON.parse(response.body)
    track = parse['tracks']['items'][0]
    name = track['name']
    albumtype = track['album']['album_type'].capitalize
    album = track['album']['name']
    artist = track['artists'][0]['name']
    url = track['external_urls']['spotify']

    m.reply "#{Format(:bold, name)} | found in the #{albumtype} #{Format(:bold, album)} by #{Format(:bold, artist)} | #{url}"
  rescue
    m.reply 'No songs found with the given parameters!'
  end

  def checkperms(m)
    updatespotify if m.user.host == CONFIG['ownerhost']
    nil
  end

  def updatespotify
    return if CONFIG['spotifyclientid'] == '' || CONFIG['spotifyclientid'].nil?
    return if CONFIG['spotifysecret'] == '' || CONFIG['spotifysecret'].nil?
    encodeid = Base64.encode64("#{CONFIG['spotifyclientid']}:#{CONFIG['spotifysecret']}")

    uri = URI.parse('https://accounts.spotify.com/api/token')
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Basic #{encodeid.delete("\n")}"
    request.set_form_data(
      'grant_type' => 'client_credentials'
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    parsed = JSON.parse(response.body)
    CONFIG['spotify'] = parsed['access_token']
    File.open(filename, 'w') { |f| f.write CONFIG.to_yaml }
  end

  def spotifyartist(m, search)
    unless checkspotifykey == true
      updatekey if checkspotifykey == 'no-key'
      if checkspotifykey == 'missing-client' || checkspotifykey == 'no-key'
        m.reply 'Missing Spotify Client Credentials! MSCC!!'
        return
      end
    end
    uri = URI.parse("https://api.spotify.com/v1/search?q=#{search}&type=artist&market=US&limit=1")
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{CONFIG['spotify']}"

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    parse = JSON.parse(response.body)
    parsed = parse['artists']['items'][0]
    artist = parsed['name']
    url = parsed['external_urls']['spotify']

    m.reply "#{Format(:bold, artist)} | #{url}"
  rescue
    m.reply 'No artists found!'
  end

  def spotifyalbum(m, search)
    unless checkspotifykey == true
      updatekey if checkspotifykey == 'no-key'
      if checkspotifykey == 'missing-client' || checkspotifykey == 'no-key'
        m.reply 'Missing Spotify Client Credentials! MSCC!!'
        return
      end
    end
    uri = URI.parse("https://api.spotify.com/v1/search?q=#{search}&type=album&market=US&limit=1")
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{CONFIG['spotify']}"

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    parse = JSON.parse(response.body)
    parsed = parse['albums']['items'][0]
    name = parsed['name']
    artist = parsed['artists'][0]['name']
    albumtype = parsed['album_type'].capitalize
    url = parsed['external_urls']['spotify']

    m.reply "#{Format(:bold, name)} | #{Format(:bold, albumtype)} by #{Format(:bold, artist)} | #{url}"
  rescue
    m.reply 'No Albums found!'
  end
end
