import csv
import sys




# shows acoustic features for tracks for the given artist

#from __future__ import print_function    # (at top of module)
from spotipy.oauth2 import SpotifyClientCredentials
import json
import spotipy
import time
import sys
import pprint
import re

#client_credentials_manager = SpotifyClientCredentials()
client_credentials_manager = SpotifyClientCredentials(client_id="0c2ec7f161354a3a9b9ada95b72a1982", client_secret="d986f32ea3f74f1e9040482abb86849d")
sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
sp.trace=True



def get_major_genre_from_artist(artist_urn):
    artist = sp.artist(artist_urn)
    #pprint.pprint(artist)
    #print(artist['genres'])
    print(artist['genres'][-1:])


def genre_contains_value(genres, value):
    for genre in genres:
        match_str = ".*%s.*" % value
        if re.match(match_str, genre):
            return True

    return False

    
csvFile = "songs_2000-2018.csv"
outCsv = open('songs_2000-2018_genre_album_numsongs.csv', 'wb')
fieldnames = ['date', 'year', 'title', 'simple_title', 'artist', 'main_artist', 'peak_pos', 'last_pos', 'weeks', 'rank', 'change', 'spotify_link', 'spotify_id', 'video_link', 'all_genre', 'main_genre', 'broad_genre', 'album', 'album_uri', 'num_songs_on_album', 'album_type', 'release_date']
writer = csv.DictWriter(outCsv, fieldnames=fieldnames)
writer.writeheader()

trackId = ""
trackUri = ""
i = 0
with open(csvFile) as billboard:
    reader = csv.DictReader(billboard)
    for row in reader:

        row['artist'] = row['artist'].encode('utf-8') 
        row['title'] = row['title'].encode('utf-8') 


        # remove featuring artists and do general cleanup
        row['artist'] = row['artist'].lower()
        row['artist'] = re.sub(" featuring.*", '', row['artist'] )
        row['artist'] = re.sub(" with .*", '', row['artist'] )
        row['artist'] = re.sub(" & .*", '', row['artist'] )
        row['artist'] = re.sub(" \/ .*", '', row['artist'] )
        row['artist'] = re.sub(" x .*", '', row['artist'] )
        row['artist'] = re.sub(" duet.*", '', row['artist'] )
        row['artist'] = re.sub("travi$", "travis", row['artist'] )
        row['artist'] = re.sub("jay z", "jay-z", row['artist'] )
        row['artist'] = re.sub("\\\"misdemeanor\\\"", "misdemeanor",  row['artist'] )
        row['artist'] = re.sub(" + .*", '', row['artist'] )
        row['artist'] = re.sub(" vs.*", '', row['artist'] )

        print row['artist'],row['title'] 

        try:
            result = sp.search(q='artist:' + row['main_artist'], type='artist')
            artist_urn = result['artists']['items'][0]['uri']  
            genres = result['artists']['items'][0]['genres']  
            main_genre = result['artists']['items'][0]['genres'][-1:]
            row['all_genre'] = genres
            row['main_genre'] = main_genre
        except:
            row['all_genre'] = "unknown"
            row['main_genre'] = "unknown"

            
        try:
            search_str = "%s %s" % (row['main_artist'], row['simple_title'])
            result = sp.search(q=search_str)

            #pprint.pprint(result)
            #print result['tracks']['items'][0]['album']['name']
            #print result['tracks']['items'][0]['album']['uri']
            #row['album_uri'] = result['albums']['items'][0]['uri']  
            #row['album'] = result['albums']['items'][0]['name'].encode('utf-8') 
            row['album_uri'] = result['tracks']['items'][0]['album']['uri'].encode('utf-8') 
            row['album'] = result['tracks']['items'][0]['album']['name'].encode('utf-8') 
            row['release_date'] = result['tracks']['items'][0]['album']['release_date'].encode('utf-8') 
            row['album_type'] = result['tracks']['items'][0]['album']['album_type'].encode('utf-8') 
        except:
            row['album_uri'] = "unknown"
            row['album'] = "unknown"
            row['release_date'] = "unknown"
            row['album_type'] = "unknown"


        #print "\n\n\n"
        #print row['all_genre']
        #print "\n\n\n"

        #row['genre'] = row['genre'].encode("utf8")
        new_genres = []
        for genre in row['all_genre']:
            genre = genre.strip()
            genre = re.sub('u\'', '\'', genre, flags=re.DOTALL)
            genre = re.sub('\[', '', genre, flags=re.DOTALL)
            genre = re.sub('\]', '', genre, flags=re.DOTALL)
            genre = re.sub('\'', '', genre, flags=re.DOTALL)

            new_genres.append(genre)

        if "urban contemporary" in new_genres:
            row['broad_genre'] = "r&b"
        elif genre_contains_value(genres, "r&b"): 
            row['broad_genre'] = "r&b"
        elif genre_contains_value(genres, "edm"): 
            row['broad_genre'] = "edm"
        elif genre_contains_value(genres, "electro"): 
            row['broad_genre'] = "edm"
        elif genre_contains_value(genres, "house"): 
            row['broad_genre'] = "edm"
        elif genre_contains_value(genres, "techno"): 
            row['broad_genre'] = "edm"
        elif genre_contains_value(genres, "country"):                 
            row['broad_genre'] = "country"
        elif genre_contains_value(genres, "rap"):                  
            row['broad_genre'] = "rap"
        elif genre_contains_value(genres, "hip hop"):                    
            row['broad_genre'] = "rap"
        elif genre_contains_value(genres, "rock"):                 
            row['broad_genre'] = "rock"
        elif genre_contains_value(genres, "folk"):                 
            row['broad_genre'] = "rock"
        elif genre_contains_value(genres, "indie"):                 
            row['broad_genre'] = "rock"
        elif genre_contains_value(genres, "pop"):                   
            row['broad_genre'] = "pop"
        elif genre_contains_value(genres, "idol"):                   
            row['broad_genre'] = "pop"
        elif genre_contains_value(genres, "boy band"):                   
            row['broad_genre'] = "pop"
        else:
            row['broad_genre'] = "unknown"


        # add num songs on the album
        try:
            tracks = sp.album_tracks(row['album_uri'])
            row['num_songs_on_album'] = tracks['total']
        except:
            row['num_songs_on_album'] = "unknown"
                        

        # print songs on album
        #for track in tracks['items']:
        #    print(track['name'])


        print row
        writer.writerow(row)
        
        i = i + 1


print "processed %s songs" % i

