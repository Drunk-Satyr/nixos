local kittyRule = hl.window_rule({
    name = "kittyRule",
    match = { 
        class = "kitty",
    },
    float = true,
    size = {800, 600},
})

kittyRule:set_enabled(false)
