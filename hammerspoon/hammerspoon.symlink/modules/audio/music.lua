
-- Music
--   Music related stuff
-----------------------------------------------
local music = {}

function music.spotifyWhatTrack()
  hs.spotify.displayCurrentTrack()
end


-- Add triggers
-----------------------------------------------
music.triggers = {}
music.triggers["Spotify What Track"] = music.spotifyWhatTrack


----------------------------------------------------------------------------
return music
