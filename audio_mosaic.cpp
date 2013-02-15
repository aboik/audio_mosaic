//
//  audio_mosaic.cpp
//  Audio Mosaic
//
//  Created by Andrew Boik on 22/01/2013.
//
//

#include "audio_mosaic.h"

#include <iostream>
#include <string>

using namespace std;

struct settings_t {
  // try to recreate the source perfectly
  bool test;
  // apply Perlin noise to dictionary pointers during reconstruction
  bool perlin;
  // snap dictionary pointers to nearest zero-crossing during reconstruction
  bool zero_crossings;
  // use a fixed number of rounds of fit activations
  bool force_iterations;
  // max fluctuation in header/tail pointer
  int perlinNoiseRange;
  // range to look for zero crossings
  int zcRange;
  // number of rounds for fit activations if force_iterations
  int num_activations
  // difference in error between fit_activations round n and fit_activations
  // round n-1 at which to stop fit_activations
  float target_error;
  // number of samples in crossfade at either end of clip
  int xfade_width;
  int window_size;
  int num_dictionary_items;
  int num_windows_in_src;
  int sample_rate;
  string audio_path;
  string target_audio;
  vector<string> source_audio;
};

settings_t mosaic_settings;

void Audio_mosaic::main() {
  // code here
}

