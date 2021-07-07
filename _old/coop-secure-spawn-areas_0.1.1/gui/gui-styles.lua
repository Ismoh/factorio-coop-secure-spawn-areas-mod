local styles = data.raw["gui-style"]["default"]

styles["cssa-mod-gui-button"] =
{
	type = "button_style",
	horizontal_align = "center",
	vertical_align = "center",
	icon_horizontal_align = "center",
	minimal_width = 36,
	height = 36,
	padding = 0,
	stretch_image_to_widget_size = true,
	default_graphical_set = base_icon_button_grahphical_set,
	hovered_graphical_set =
    {
		base = {position = {34, 17}, corner_size = 2, draw_type = "outer", opacity = 0.5},
        shadow = default_dirt,
        glow = default_glow(default_glow_color, 0.5)
	},
	clicked_graphical_set =
	{
		base   = {position = {51, 17}, corner_size = 2, draw_type = "outer", opacity = 0.5},
        shadow = default_dirt
	},
	selected_graphical_set =
	{
		base   = {position = {225, 17}, corner_size = 2, draw_type = "outer", opacity = 0.5},
		shadow = default_dirt
	},
	selected_hovered_graphical_set =
	{
		base   = {position = {369, 17}, corner_size = 2, draw_type = "outer", opacity = 0.5},
		shadow = default_dirt
	},
	strikethrough_color = {0.5, 0.5, 0.5},
	pie_progress_color = {1, 1, 1},
	left_click_sound =
	{
		{ filename = "__core__/sound/gui-click.ogg" }
	},
	draw_shadow_under_picture = true
}

styles["cssa-title-flow"] =
{
	type = "horizontal_flow_style",
    horizontal_align = "center",
	vertically_stretchable = "off",
	natural_width = 500,
    padding = 1,
	margin = 1
}

styles["cssa-top-right-close-button"] =
{
	type               = "button_style",
	parent             = "frame_button",
	size               = 24,
	left_click_sound   = {{ filename = "__core__/sound/gui-red-button.ogg", volume = 0.7 }},
	default_graphical_set =
	{
		base = {position = {136, 17}, corner_size = 8},
		shadow = default_shadow
	},
	hovered_graphical_set =
	{
		base = {position = {170, 17}, corner_size = 8},
		shadow = default_shadow,
		glow = default_glow(red_button_glow_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position = {187, 17}, corner_size = 8},
		shadow = default_shadow
	},
	disabled_graphical_set =
	{
		base = {position = {153, 17}, corner_size = 8},
		shadow = default_shadow
	}
}