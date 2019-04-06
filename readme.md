This is an approach for an item transfer api for minetest mods.  
Please read `api.txt` to see contents. The file is unfinished, but the sceleton is done.  

These are the goals for the api:  
- Everything that is possible with pipeworks should still be possible.  
- Helper-functions should help the modder and be lightweight.  
- All cases should be covered.  
- The item transfer of items should be done via the api. Liquids and other things are ignored.  
- It should be attractive enought for modders to use it.  
- All minetest-versions 5.0+ should be supported.  

Stop reading here if this is a fork and not DS-minetest's reopsitory.  

Please, if you see anything that is missing, open an issue!  
Please do the same if you find any other problems, want to suggest something and the like.  
You can also make PRs and issues to help me with my todo list (see below).  
And you can reach me per forum pm. : )

todo:  
- decide about things  
- what should I do with the scenarios? make them to a tutorial or to examples? remove them entirely? add more?  
- think about what helper functions might be needed  
- add helper functions  
- override nodes of commonly used mods (especially minetest_game mods) to use this api, use optional dependencies here  
- documentation stuff  
- test this  
- fix the readme if it's currently uggly  
- add points to this todo list that are missing  

:cat2:  
