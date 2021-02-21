# aaaaaaaaa

aaAaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHH

## TODO

### MVP

- [x] 💚 MVP idea
    - **Base genre:** platformer + bullet-hell-ish shooter (but without enemy bullets)
    - The environment is empty initially. Blocks are falling down, filling the environment. The blocks can hit the
      player.
    - **Win state:** The player can jump onto the fallen blocks. Once high enough, the level is won.
    - **Lose state:** The player loses HP constantly. The more blocks the player has been hit by so far in the level,
      the higher the rate of HP loss. The only way to recover HP is to spam the A button (in the context of the game,
      the `A`
      button is the screaming button, and the "HP" is the inverse of the player character's stress level).
    - **Main gameplay feature:** The key configuration is very messy in the first place (apart from the `A` key, there
      are also the following keys: `X`, `space bar`, `P`, `8` and `B`) but what makes it even more difficult is that at
      a regular period, the key configuration is changed. The player should be given a dozen seconds to get used to the
      new keys, during which the falling blocks are frozen in place and can't hurt the player.
    - **Important:** There will be quite a bit of RNG, but it will be deterministic and consistent. Basically, every
      level will play out the same way. For example, the same kinds of blocks will fall at the same positions, and the
      key configuration will be changed in the same way at the same moments every time the same level is played. Any RNG
      that can't be made consistent (e.g. spreading the player's bullets randomly) should be avoided.
    - **Non-MVP features/ideas:**
        - For the MVP there will be only one level. Of course, the very next thing after the MVP should be to add more
          levels.
        - The player can shoot at the blocks to destroy them if in a bad spot.
            - For the MVP, they shouldn't drop anything. However, later maybe they can drop some score, powerups, etc.
        - The period at which the keys are scrambled is initially around one minute, but with every passing level, this
          period becomes lower and lower. This not only may make it more frustrating, but also if the player is
          speedrunning, it would be annoying to wait for the freeze periods.
        - After every level, the player is offered to choose one among 3-5 permanent powerups (e.g. faster speed, higher
          jumping, faster shooting rate, bigger bullets, faster bullets, more damage, more max HP, lower HP loss rate,
          more screaming effectiveness, higher key scramble period and so on).
            - Maybe also make every upgrade be paired up with a downgrade to make it more interesting (probably the
              opposite of each upgrade, but with a lower intensity).
- [x] 💙 Main menu (for now only a 'New game' and 'Exit' buttons)
- [x] 💙 A platformer player in a barren environment (line collision at the bottom Y and left/right X). The player can
  move and jump around.
- [x] 💙 The controls are scrambled every 60 seconds.
- [x] 💙 Control preview on the right side of the screen, like this (<, > and j are the icons for the 'move_left',
  'move_right' and 'jump' actions, and A, B and C are the icons of the input keys):

```
  C
  j
A< >B
```

- [x] 💙 Falling blocks. They don't do anything to the player for now and just fall into place (in a grid-like
  structure). They fall at a constant speed as opposed to a linearly increasing one. When they fall into place, the
  blocks themselves are removed and replaced with a TileMap tile.
    - The blocks should have a one-way collision until they fall down. When they're down, they should wait for the
      player to be far away enough before they materialize (e.g. at least half of a cell away in both axes).
    - The way it works is that at a specific level above the player camera, blocks are spawned (horizontally, for each
      cell, it is decided randomly whether the cell will have a corresponding falling block; maybe later it can be made
      with simplex noise or something). The tricky part is when the camera moves up and down, and it isn't clear how
      this will be implemented yet.
    - At every update, `target_spawn_y = player.y - WINDOW_HEIGHT - CELL_HEIGHT`
    - At the beginning, `next_spawn_y = target_spawn_y`
    - At every update, `next_spawn_y += BLOCK_FALL_SPEED * delta` and `block.position.y += BLOCK_FALL_SPEED * delta`
    - At every update, `while next_spawn_y >= target_spawn_y:` `spawn_row(next_spawn_y)`
      and `next_spawn_y -= CELL_HEIGHT`
    - Also, keep the next (upper) layer that is to be created later so that it can be determined whether the new blocks
      will have blocks above them so that their texture can be determined correctly.
- [x] 💙 The falling blocks should explode when their bottom collides with the player.
- [x] 💙 When the player reaches Y=0 (which is shown with a Line2D for now), the game is won (no win screen; only a
  player win animation, and an overlay message asking the player to press space to restart).
- [x] 💙 Player HP, which goes down at a constant speed. When the HP reaches 0, the game is lost. Player HP preview on
  the right side of the screen.
- [x] 💙 Screaming mechanic. Pressing `A` makes 'A' characters appear above the player. The first 9 As are lowercase and
  don't heal much. Afterwards, they're capital letters, and each subsequent one heals more than the previous one.
- [x] 💙 The player can be hit by the falling blocks (their underside, to be specific). When hit, the falling block is
  destroyed, and the player's HP starts going down faster.
- [x] 💙 Player HP preview on the right side of the screen
- [x] 💙 Let the player hold down the A key instead of spam-pressing it. Stressing the player out may be on the menu,
  but injuring their left hand and keyboard isn't.
- [x] 💟 Publish `0.1`

### Basic features

- [x] 💙 Prevent the logger from trying to create log files unnecessarily
- [x] 💜 Make textures for the blocks and environment that are specific to this game rather than reusing the old ones.
- [x] 💙 When the player HP is low, show the HP bar where the character is
- [x] 💙 When the inputs have changed, stop the falling blocks for a while and show the inputs close to the character
- [x] 💙 The falling blocks are slow initially, and their speed gradually increases
- [x] 💜 Create a player sprite/animation for this game.
- [ ] 💙 Screen shake when screaming
- [ ] 💟💜 Game icon
- [ ] 💙 (Performance) Use a one-second timer to update the right-side time label text instead of updating it at
  every `_process` call
- [ ] 💙 Make the non-pressed control previews slightly transparent so that the controls feel more responsive
- [ ] 💛 Menu sounds
- [ ] 💙 Sound configuration for the menu
- [ ] 💛 Player hit sound
- [ ] 💛 Win sound
- [ ] 💛 Lose sound
- [ ] 💛 Main menu music
- [ ] 💛 World music (including when the game is paused between levels)
- [ ] 💟💜 Cover image (630x500 or upscaled 315x250)
- [ ] 💟💜 Screenshots
- [ ] 💙💜 Player trail particle effects
- [ ] 💟 Publish `0.2`

### Advanced features

- [ ] 💙 More levels
- [ ] 💙 The progress is saved automatically after each level. At the end of the level, the player is given two
  options: 'Next level' and 'Main menu'. Also, the player should be informed that the progress has been saved. Note that
  starting a new game does not erase the old progress until the level has been won. After the last level, the player is
  invited to an Easter-egg-ish room. (No idea what it will contain yet)
- [ ] 💜 Some background decorations
- [ ] 💙 When starting a new game, if there is already some saved progress, warn the player that upon the completion of
  the first level, the previous progress will be lost forever.
- [ ] 💙 Ability to load the progress with a 'Continue' button (visible only if there's already a saved game).
- [ ] 💙 Keep track of the total time.
- [ ] 💙 Player shooting
- [ ] 💛 Shooting sound
- [ ] 💙💜 Block destruction (appearing as progressive cracks no the blocks rather than health bars)
- [ ] 💛 Block hit sound
- [ ] 💙 End-level upgrades
- [ ] 💙 The player bullets can damage tiles as well

### Expert features

---

#### Legend

- 💙 Code/Godot
- 💜 Art
- 💚 Design
- 💛 Audio
- 💟 Special
