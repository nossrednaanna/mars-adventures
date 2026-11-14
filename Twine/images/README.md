# Story images

Put story image files in this folder. From passages in `Twine/Stories/testing.html`, reference them with:

```html
<img class="story-image" src="../images/your-image.jpg" alt="Describe the image">
```

For a full-passage background, use:

```html
<div class="scene-page" style="background-image: url('../images/your-image.jpg');">
  <div class="scene-content">
    Your passage text and links go here.
  </div>
</div>
```

The `../images/` path works from both the `Stories` and `Scratch` folders. If you publish the story somewhere else, keep the same relative folder structure or update the paths.

When `Twine/build_story.rb` builds the local story, it converts these relative paths to absolute `file://` URLs. This allows Twine's temporary Play preview to load the project images. Rebuild the story after moving the project to a different folder so the local URLs are refreshed.

## Astronaut portraits

The seven generated children's-book portraits are:

- `astronaut-engineer.png`
- `astronaut-researcher.png`
- `astronaut-medic.png`
- `astronaut-programer.png`
- `astronaut-modeler.png`
- `astronaut-electrician.png`
- `astronaut-astrophysicist.png`

They are transparent 1254 × 1254 PNG files used by the opening roster, character-selection cards, and persistent crew status bar.
