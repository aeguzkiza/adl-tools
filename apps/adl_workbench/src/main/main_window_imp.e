indexing
	description: "Objects that represent an EV_TITLED_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MAIN_WINDOW_IMP

inherit
	EV_TITLED_WINDOW
		redefine
			initialize, is_in_default_state
		end
			
	CONSTANTS
		undefine
			is_equal, default_create, copy
		end

-- This class is the implementation of an EV_TITLED_WINDOW generated by EiffelBuild.
-- You should not modify this code by hand, as it will be re-generated every time
-- modifications are made to the project.

feature {NONE}-- Initialization

	initialize is
			-- Initialize `Current'.
		local
			internal_font: EV_FONT
		do
			Precursor {EV_TITLED_WINDOW}
			initialize_constants
			
				-- Create all widgets.
			create menu
			create file_menu
			create open_adl_file_mi
			create l_ev_menu_separator_1
			create save_adl_file_mi
			create l_ev_menu_separator_2
			create exit_tool_mi
			create options_menu
			create options
			create help_menu
			create icon_help_mi
			create news
			create online_mi
			create l_ev_menu_separator_3
			create about_mi
			create main
			create action_bar
			create open_button
			create parse_button
			create edit_button
			create save_button
			create format_label
			create format_combo
			create archetype_id
			create l_ev_label_1
			create parent_archetype_id
			create language_label
			create language_combo
			create explorer_view_area
			create archetype_file_tree
			create total_view_area
			create arch_notebook
			create arch_desc_area_vbox
			create author_lang_term_hbox
			create arch_desc_auth_frame
			create l_ev_vertical_box_1
			create arch_desc_status_hbox
			create arch_desc_status_label
			create arch_desc_status_text
			create arch_desc_auth_hbox
			create arch_desc_auth_orig_auth_label
			create arch_desc_auth_orig_auth_mlist
			create arch_desc_contrib_hbox
			create arch_desc_auth_contrib_label
			create arch_desc_auth_contrib_list
			create lang_term_frame
			create l_ev_horizontal_box_1
			create lang_hbox
			create languages_label
			create languages_list
			create term_hbox
			create terminologies_label
			create terminologies_list
			create arch_desc_details_frame
			create arch_desc_details_hbox
			create l_ev_vertical_box_2
			create l_ev_horizontal_box_2
			create arch_desc_purpose_label
			create arch_desc_purpose_text
			create l_ev_horizontal_box_3
			create arch_desc_use_label
			create arch_desc_use_text
			create l_ev_horizontal_box_4
			create arch_desc_misuse_label
			create arch_desc_misuse_text
			create l_ev_horizontal_box_5
			create arch_desc_keywords_label
			create arch_desc_keywords_list
			create arch_desc_resource_frame
			create l_ev_vertical_box_3
			create l_ev_horizontal_box_6
			create arch_desc_resource_package_label
			create arch_desc_resource_package_text
			create l_ev_horizontal_box_7
			create arch_desc_resource_orig_res_label
			create arch_desc_resource_orig_res_mlist
			create arch_desc_copyright_hbox
			create arch_desc_copyright_label
			create arch_desc_copyright_text
			create info_view_area
			create source_notebook
			create parsed_archetype_tree_view
			create parsed_archetype_tree
			create tree_controls
			create tree_expand
			create tree_expand_one
			create tree_shrink_one
			create tree_technical_node
			create parsed_archetype_found_paths
			create ontology_notebook
			create ontology_term_defs
			create ontology_constraint_defs
			create archetype_text_edit_area
			create parser_status_area
			
				-- Build_widget_structure.
			set_menu_bar (menu)
			menu.extend (file_menu)
			file_menu.extend (open_adl_file_mi)
			file_menu.extend (l_ev_menu_separator_1)
			file_menu.extend (save_adl_file_mi)
			file_menu.extend (l_ev_menu_separator_2)
			file_menu.extend (exit_tool_mi)
			menu.extend (options_menu)
			options_menu.extend (options)
			menu.extend (help_menu)
			help_menu.extend (icon_help_mi)
			help_menu.extend (news)
			help_menu.extend (online_mi)
			help_menu.extend (l_ev_menu_separator_3)
			help_menu.extend (about_mi)
			extend (main)
			main.extend (action_bar)
			action_bar.extend (open_button)
			action_bar.extend (parse_button)
			action_bar.extend (edit_button)
			action_bar.extend (save_button)
			action_bar.extend (format_label)
			action_bar.extend (format_combo)
			action_bar.extend (archetype_id)
			action_bar.extend (l_ev_label_1)
			action_bar.extend (parent_archetype_id)
			action_bar.extend (language_label)
			action_bar.extend (language_combo)
			main.extend (explorer_view_area)
			explorer_view_area.extend (archetype_file_tree)
			explorer_view_area.extend (total_view_area)
			total_view_area.extend (arch_notebook)
			arch_notebook.extend (arch_desc_area_vbox)
			arch_desc_area_vbox.extend (author_lang_term_hbox)
			author_lang_term_hbox.extend (arch_desc_auth_frame)
			arch_desc_auth_frame.extend (l_ev_vertical_box_1)
			l_ev_vertical_box_1.extend (arch_desc_status_hbox)
			arch_desc_status_hbox.extend (arch_desc_status_label)
			arch_desc_status_hbox.extend (arch_desc_status_text)
			l_ev_vertical_box_1.extend (arch_desc_auth_hbox)
			arch_desc_auth_hbox.extend (arch_desc_auth_orig_auth_label)
			arch_desc_auth_hbox.extend (arch_desc_auth_orig_auth_mlist)
			l_ev_vertical_box_1.extend (arch_desc_contrib_hbox)
			arch_desc_contrib_hbox.extend (arch_desc_auth_contrib_label)
			arch_desc_contrib_hbox.extend (arch_desc_auth_contrib_list)
			author_lang_term_hbox.extend (lang_term_frame)
			lang_term_frame.extend (l_ev_horizontal_box_1)
			l_ev_horizontal_box_1.extend (lang_hbox)
			lang_hbox.extend (languages_label)
			lang_hbox.extend (languages_list)
			l_ev_horizontal_box_1.extend (term_hbox)
			term_hbox.extend (terminologies_label)
			term_hbox.extend (terminologies_list)
			arch_desc_area_vbox.extend (arch_desc_details_frame)
			arch_desc_details_frame.extend (arch_desc_details_hbox)
			arch_desc_details_hbox.extend (l_ev_vertical_box_2)
			l_ev_vertical_box_2.extend (l_ev_horizontal_box_2)
			l_ev_horizontal_box_2.extend (arch_desc_purpose_label)
			l_ev_horizontal_box_2.extend (arch_desc_purpose_text)
			l_ev_vertical_box_2.extend (l_ev_horizontal_box_3)
			l_ev_horizontal_box_3.extend (arch_desc_use_label)
			l_ev_horizontal_box_3.extend (arch_desc_use_text)
			l_ev_vertical_box_2.extend (l_ev_horizontal_box_4)
			l_ev_horizontal_box_4.extend (arch_desc_misuse_label)
			l_ev_horizontal_box_4.extend (arch_desc_misuse_text)
			arch_desc_details_hbox.extend (l_ev_horizontal_box_5)
			l_ev_horizontal_box_5.extend (arch_desc_keywords_label)
			l_ev_horizontal_box_5.extend (arch_desc_keywords_list)
			arch_desc_area_vbox.extend (arch_desc_resource_frame)
			arch_desc_resource_frame.extend (l_ev_vertical_box_3)
			l_ev_vertical_box_3.extend (l_ev_horizontal_box_6)
			l_ev_horizontal_box_6.extend (arch_desc_resource_package_label)
			l_ev_horizontal_box_6.extend (arch_desc_resource_package_text)
			l_ev_vertical_box_3.extend (l_ev_horizontal_box_7)
			l_ev_horizontal_box_7.extend (arch_desc_resource_orig_res_label)
			l_ev_horizontal_box_7.extend (arch_desc_resource_orig_res_mlist)
			arch_desc_area_vbox.extend (arch_desc_copyright_hbox)
			arch_desc_copyright_hbox.extend (arch_desc_copyright_label)
			arch_desc_copyright_hbox.extend (arch_desc_copyright_text)
			arch_notebook.extend (info_view_area)
			info_view_area.extend (source_notebook)
			source_notebook.extend (parsed_archetype_tree_view)
			parsed_archetype_tree_view.extend (parsed_archetype_tree)
			parsed_archetype_tree_view.extend (tree_controls)
			tree_controls.extend (tree_expand)
			tree_controls.extend (tree_expand_one)
			tree_controls.extend (tree_shrink_one)
			tree_controls.extend (tree_technical_node)
			source_notebook.extend (parsed_archetype_found_paths)
			info_view_area.extend (ontology_notebook)
			ontology_notebook.extend (ontology_term_defs)
			ontology_notebook.extend (ontology_constraint_defs)
			arch_notebook.extend (archetype_text_edit_area)
			total_view_area.extend (parser_status_area)
			
			file_menu.set_text ("File")
			open_adl_file_mi.set_text ("Open ")
			save_adl_file_mi.disable_sensitive
			save_adl_file_mi.set_text ("Save")
			exit_tool_mi.set_text ("Exit")
			options_menu.set_text ("Options")
			options.set_text ("set options...")
			help_menu.set_text ("Help")
			icon_help_mi.set_text ("Icons ")
			news.set_text ("News")
			online_mi.set_text ("online...")
			about_mi.set_text ("About ")
			main.set_background_color (create {EV_COLOR}.make_with_8_bit_rgb (255, 255, 206))
			main.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			main.set_minimum_width (app_min_width)
			main.set_minimum_height (main_vbox_min_height)
			main.disable_item_expand (action_bar)
			action_bar.set_background_color (create {EV_COLOR}.make_with_8_bit_rgb (255, 255, 206))
			action_bar.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			action_bar.set_minimum_width (800)
			action_bar.set_padding_width (10)
			action_bar.set_border_width (5)
			action_bar.disable_item_expand (open_button)
			action_bar.disable_item_expand (parse_button)
			action_bar.disable_item_expand (edit_button)
			action_bar.disable_item_expand (save_button)
			action_bar.disable_item_expand (format_label)
			action_bar.disable_item_expand (format_combo)
			action_bar.disable_item_expand (l_ev_label_1)
			action_bar.disable_item_expand (language_label)
			action_bar.disable_item_expand (language_combo)
			open_button.set_background_color (button_colour)
			open_button.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			open_button.set_text ("Open")
			open_button.set_tooltip ("open new archetype")
			open_button.set_minimum_width (40)
			open_button.set_minimum_height (23)
			parse_button.set_background_color (button_colour)
			parse_button.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			parse_button.set_text ("Parse")
			parse_button.set_tooltip ("parse currently loaded archetype")
			parse_button.set_minimum_width (40)
			edit_button.set_background_color (button_colour)
			edit_button.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			edit_button.set_text ("Edit")
			edit_button.set_tooltip ("Edit archetype with external editor")
			edit_button.set_minimum_width (40)
			edit_button.set_minimum_height (23)
			save_button.set_background_color (button_colour)
			save_button.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			save_button.set_text ("Save")
			save_button.set_tooltip ("save currently loaded archetype")
			save_button.set_minimum_width (40)
			format_label.set_background_color (background)
			format_label.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			format_label.set_text ("as")
			format_label.set_minimum_width (15)
			format_combo.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			format_combo.set_tooltip ("Select save format")
			format_combo.set_minimum_width (45)
			archetype_id.set_background_color (background)
			archetype_id.set_minimum_width (200)
			archetype_id.disable_edit
			l_ev_label_1.set_background_color (background)
			l_ev_label_1.set_text ("specializes")
			parent_archetype_id.set_background_color (background)
			parent_archetype_id.set_minimum_width (200)
			parent_archetype_id.disable_edit
			language_label.set_background_color (background)
			language_label.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			language_label.set_text ("Language")
			language_label.set_minimum_width (50)
			language_label.set_minimum_height (23)
			language_combo.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			language_combo.set_tooltip ("Language")
			language_combo.set_minimum_width (40)
			language_combo.set_minimum_height (23)
			explorer_view_area.set_minimum_width (app_min_width)
			explorer_view_area.set_minimum_height (main_hbox_min_height)
			total_view_area.set_minimum_width (app_min_width)
			total_view_area.set_minimum_height (app_min_height)
			arch_notebook.set_background_color (background)
			arch_notebook.set_minimum_width (app_min_width)
			arch_notebook.set_minimum_height (arch_notebook_min_height)
			arch_notebook.set_item_text (arch_desc_area_vbox, "Description")
			arch_notebook.set_item_text (info_view_area, "Definition")
			arch_notebook.set_item_text (archetype_text_edit_area, "Source")
			arch_desc_area_vbox.set_background_color (background)
			arch_desc_area_vbox.disable_item_expand (arch_desc_details_frame)
			arch_desc_area_vbox.disable_item_expand (arch_desc_resource_frame)
			arch_desc_area_vbox.disable_item_expand (arch_desc_copyright_hbox)
			author_lang_term_hbox.set_background_color (background)
			author_lang_term_hbox.disable_item_expand (lang_term_frame)
			arch_desc_auth_frame.set_background_color (background)
			arch_desc_auth_frame.set_text ("authorship")
			l_ev_vertical_box_1.set_background_color (background)
			l_ev_vertical_box_1.disable_item_expand (arch_desc_status_hbox)
			arch_desc_status_hbox.set_background_color (background)
			arch_desc_status_hbox.disable_item_expand (arch_desc_status_label)
			arch_desc_status_hbox.disable_item_expand (arch_desc_status_text)
			arch_desc_status_label.set_background_color (background)
			arch_desc_status_label.set_font (label_font)
			arch_desc_status_label.set_text ("status: ")
			arch_desc_status_label.set_minimum_width (desc_label_width)
			arch_desc_status_text.set_minimum_width (100)
			arch_desc_status_text.disable_edit
			arch_desc_auth_hbox.set_background_color (background)
			arch_desc_auth_hbox.disable_item_expand (arch_desc_auth_orig_auth_label)
			arch_desc_auth_orig_auth_label.set_background_color (background)
			arch_desc_auth_orig_auth_label.set_font (label_font)
			arch_desc_auth_orig_auth_label.set_text ("original%Nauthor:")
			arch_desc_auth_orig_auth_label.set_minimum_width (desc_label_width)
			arch_desc_auth_orig_auth_mlist.set_minimum_width (300)
			arch_desc_contrib_hbox.set_background_color (background)
			arch_desc_contrib_hbox.disable_item_expand (arch_desc_auth_contrib_label)
			arch_desc_auth_contrib_label.set_background_color (background)
			arch_desc_auth_contrib_label.set_font (label_font)
			arch_desc_auth_contrib_label.set_text ("contributors:")
			arch_desc_auth_contrib_label.set_minimum_width (desc_label_width)
			arch_desc_auth_contrib_list.set_minimum_width (300)
			lang_term_frame.set_background_color (background)
			lang_term_frame.set_text ("Languages and Terminologies")
			l_ev_horizontal_box_1.set_background_color (background)
			l_ev_horizontal_box_1.disable_item_expand (lang_hbox)
			l_ev_horizontal_box_1.disable_item_expand (term_hbox)
			lang_hbox.set_background_color (background)
			lang_hbox.disable_item_expand (languages_label)
			languages_label.set_background_color (background)
			languages_label.set_font (label_font)
			languages_label.set_text ("Languages:")
			languages_label.set_minimum_width (desc_label_width)
			languages_list.set_minimum_width (100)
			languages_list.set_minimum_height (80)
			term_hbox.set_background_color (background)
			term_hbox.disable_item_expand (terminologies_label)
			terminologies_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			terminologies_label.set_font (internal_font)
			terminologies_label.set_text ("Terminologies:")
			terminologies_label.set_minimum_width (desc_label_width)
			terminologies_list.set_minimum_width (100)
			terminologies_list.set_minimum_height (80)
			arch_desc_details_frame.set_background_color (background)
			arch_desc_details_frame.set_text ("details")
			arch_desc_details_hbox.set_background_color (background)
			l_ev_vertical_box_2.set_background_color (background)
			l_ev_horizontal_box_2.set_background_color (background)
			l_ev_horizontal_box_2.disable_item_expand (arch_desc_purpose_label)
			arch_desc_purpose_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			arch_desc_purpose_label.set_font (internal_font)
			arch_desc_purpose_label.set_text ("purpose")
			arch_desc_purpose_label.set_minimum_width (desc_label_width)
			arch_desc_purpose_text.set_minimum_width (300)
			arch_desc_purpose_text.set_minimum_height (66)
			l_ev_horizontal_box_3.set_background_color (background)
			l_ev_horizontal_box_3.disable_item_expand (arch_desc_use_label)
			arch_desc_use_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			arch_desc_use_label.set_font (internal_font)
			arch_desc_use_label.set_text ("use:")
			arch_desc_use_label.set_minimum_width (desc_label_width)
			arch_desc_use_text.set_minimum_width (300)
			arch_desc_use_text.set_minimum_height (66)
			l_ev_horizontal_box_4.set_background_color (background)
			l_ev_horizontal_box_4.disable_item_expand (arch_desc_misuse_label)
			arch_desc_misuse_label.set_background_color (background)
			arch_desc_misuse_label.set_font (label_font)
			arch_desc_misuse_label.set_text ("misuse:")
			arch_desc_misuse_label.set_minimum_width (desc_label_width)
			arch_desc_misuse_text.set_minimum_width (300)
			arch_desc_misuse_text.set_minimum_height (66)
			l_ev_horizontal_box_5.set_background_color (background)
			l_ev_horizontal_box_5.disable_item_expand (arch_desc_keywords_label)
			arch_desc_keywords_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			arch_desc_keywords_label.set_font (internal_font)
			arch_desc_keywords_label.set_text ("keywords:")
			arch_desc_keywords_label.set_minimum_width (75)
			arch_desc_keywords_list.set_minimum_width (200)
			arch_desc_keywords_list.set_minimum_height (66)
			arch_desc_resource_frame.set_background_color (background)
			arch_desc_resource_frame.set_text ("resources")
			l_ev_vertical_box_3.set_background_color (background)
			l_ev_vertical_box_3.disable_item_expand (l_ev_horizontal_box_6)
			l_ev_vertical_box_3.disable_item_expand (l_ev_horizontal_box_7)
			l_ev_horizontal_box_6.set_background_color (background)
			l_ev_horizontal_box_6.disable_item_expand (arch_desc_resource_package_label)
			arch_desc_resource_package_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			arch_desc_resource_package_label.set_font (internal_font)
			arch_desc_resource_package_label.set_text ("package:")
			arch_desc_resource_package_label.set_minimum_width (desc_label_width)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_regular)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("Microsoft Sans Serif")
			arch_desc_resource_package_text.set_font (internal_font)
			arch_desc_resource_package_text.set_minimum_width (300)
			arch_desc_resource_package_text.disable_edit
			l_ev_horizontal_box_7.set_background_color (background)
			l_ev_horizontal_box_7.disable_item_expand (arch_desc_resource_orig_res_label)
			arch_desc_resource_orig_res_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			arch_desc_resource_orig_res_label.set_font (internal_font)
			arch_desc_resource_orig_res_label.set_text ("original%Nresources:")
			arch_desc_resource_orig_res_label.set_minimum_width (desc_label_width)
			arch_desc_copyright_hbox.set_background_color (background)
			arch_desc_copyright_hbox.disable_item_expand (arch_desc_copyright_label)
			arch_desc_copyright_label.set_background_color (background)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_bold)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("System")
			arch_desc_copyright_label.set_font (internal_font)
			arch_desc_copyright_label.set_text ("copyright: ")
			arch_desc_copyright_label.set_minimum_width (desc_label_width)
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_sans)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_regular)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (10)
			internal_font.preferred_families.extend ("Microsoft Sans Serif")
			arch_desc_copyright_text.set_font (internal_font)
			arch_desc_copyright_text.set_minimum_height (44)
			info_view_area.set_background_color (background)
			info_view_area.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			info_view_area.set_minimum_width (0)
			info_view_area.set_minimum_height (0)
			source_notebook.set_background_color (background)
			source_notebook.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			source_notebook.set_minimum_width (source_notebook_min_width)
			source_notebook.set_minimum_height (source_notebook_min_height)
			source_notebook.set_item_text (parsed_archetype_tree_view, "Node map")
			source_notebook.set_item_text (parsed_archetype_found_paths, "Path map")
			parsed_archetype_tree_view.set_background_color (background)
			parsed_archetype_tree_view.set_minimum_width (source_notebook_min_width)
			parsed_archetype_tree_view.set_minimum_height (arch_tree_min_height)
			parsed_archetype_tree_view.disable_item_expand (tree_controls)
			parsed_archetype_tree.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			parsed_archetype_tree.set_minimum_width (arch_tree_min_width)
			parsed_archetype_tree.set_minimum_height (arch_tree_min_height)
			tree_controls.set_background_color (background)
			tree_controls.set_minimum_width (110)
			tree_controls.set_minimum_height (app_min_height)
			tree_controls.set_padding_width (15)
			tree_controls.set_border_width (10)
			tree_controls.disable_item_expand (tree_expand)
			tree_controls.disable_item_expand (tree_expand_one)
			tree_controls.disable_item_expand (tree_shrink_one)
			tree_controls.disable_item_expand (tree_technical_node)
			tree_expand.set_background_color (button_colour)
			tree_expand.set_text ("Expand/Collapse all")
			tree_expand.set_tooltip ("Completely expand or collapse node map")
			tree_expand.set_minimum_width (tree_control_panel_width)
			tree_expand_one.set_background_color (button_colour)
			tree_expand_one.set_text ("Expand one")
			tree_expand_one.set_tooltip ("Expand node map one level")
			tree_expand_one.set_minimum_width (tree_control_panel_width)
			tree_shrink_one.set_background_color (button_colour)
			tree_shrink_one.set_text ("Collapse one")
			tree_shrink_one.set_tooltip ("Collapse node map one level")
			tree_shrink_one.set_minimum_width (tree_control_panel_width)
			tree_technical_node.set_background_color (button_colour)
			tree_technical_node.set_text ("Technical")
			tree_technical_node.set_tooltip ("Toggle inclusion of technical details")
			tree_technical_node.set_minimum_width (tree_control_panel_width)
			parsed_archetype_found_paths.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			parsed_archetype_found_paths.set_minimum_width (0)
			parsed_archetype_found_paths.set_minimum_height (0)
			ontology_notebook.set_background_color (background)
			ontology_notebook.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			ontology_notebook.set_minimum_width (0)
			ontology_notebook.set_minimum_height (min_terms_height)
			ontology_notebook.set_item_text (ontology_term_defs, "Term Defs")
			ontology_notebook.set_item_text (ontology_constraint_defs, "Constraint Defs")
			ontology_term_defs.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			ontology_term_defs.set_minimum_width (0)
			ontology_term_defs.set_minimum_height (0)
			ontology_constraint_defs.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			ontology_constraint_defs.set_minimum_width (0)
			ontology_constraint_defs.set_minimum_height (0)
			archetype_text_edit_area.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			create internal_font
			internal_font.set_family (feature {EV_FONT_CONSTANTS}.Family_typewriter)
			internal_font.set_weight (feature {EV_FONT_CONSTANTS}.Weight_regular)
			internal_font.set_shape (feature {EV_FONT_CONSTANTS}.Shape_regular)
			internal_font.set_height_in_points (9)
			internal_font.preferred_families.extend ("Courier New")
			archetype_text_edit_area.set_font (internal_font)
			archetype_text_edit_area.set_minimum_width (600)
			archetype_text_edit_area.set_minimum_height (app_min_height)
			archetype_text_edit_area.disable_edit
			parser_status_area.set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			parser_status_area.set_minimum_width (0)
			parser_status_area.set_minimum_height (status_area_min_height)
			parser_status_area.disable_edit
			set_background_color (create {EV_COLOR}.make_with_8_bit_rgb (255, 255, 206))
			set_foreground_color (create {EV_COLOR}.make_with_8_bit_rgb (64, 0, 0))
			set_minimum_width (app_min_width)
			set_minimum_height (app_min_height)
			set_maximum_width (app_max_width)
			set_maximum_height (app_max_height)
			set_title ("Archetype Ddefinition Language VER Workbench")
			
				--Connect events.
			open_adl_file_mi.select_actions.extend (agent open_adl_file)
			save_adl_file_mi.select_actions.extend (agent save_adl_file)
			exit_tool_mi.select_actions.extend (agent exit_app)
			options.select_actions.extend (agent set_options)
			icon_help_mi.select_actions.extend (agent display_icon_help)
			news.select_actions.extend (agent display_news)
			online_mi.select_actions.extend (agent show_online_help)
			about_mi.select_actions.extend (agent display_about)
			open_button.select_actions.extend (agent open_adl_file)
			parse_button.select_actions.extend (agent parse_archetype)
			edit_button.select_actions.extend (agent edit_archetype)
			save_button.select_actions.extend (agent save_adl_file)
			format_combo.select_actions.extend (agent select_format)
			language_combo.select_actions.extend (agent select_language)
			archetype_file_tree.select_actions.extend (agent archetype_tree_item_select)
			parsed_archetype_tree.select_actions.extend (agent node_map_item_select)
			tree_expand.select_actions.extend (agent expand_tree)
			tree_expand_one.select_actions.extend (agent expand_tree_one_level)
			tree_shrink_one.select_actions.extend (agent shrink_tree_one_level)
			tree_technical_node.select_actions.extend (agent tree_technical_mode)
			archetype_text_edit_area.pointer_button_press_actions.extend (agent move_cursor_to_pointer_location (?, ?, ?, ?, ?, ?, ?, ?))
			archetype_text_edit_area.pointer_double_press_actions.extend (agent pointer_double_click_action (?, ?, ?, ?, ?, ?, ?, ?))
			archetype_text_edit_area.key_press_string_actions.extend (agent process_keystroke (?))
			close_request_actions.extend (agent exit_app)
				-- Close the application when an interface close
				-- request is recieved on `Current'. i.e. the cross is clicked.

				-- Call `user_initialization'.
			user_initialization
		end

feature -- Access

	format_combo, language_combo: EV_COMBO_BOX
	l_ev_menu_separator_1, l_ev_menu_separator_2, l_ev_menu_separator_3: EV_MENU_SEPARATOR
	archetype_id,
	parent_archetype_id, arch_desc_status_text, arch_desc_resource_package_text: EV_TEXT_FIELD
	arch_desc_auth_orig_auth_mlist,
	arch_desc_resource_orig_res_mlist, parsed_archetype_found_paths, ontology_term_defs,
	ontology_constraint_defs: EV_MULTI_COLUMN_LIST
	file_menu, options_menu, help_menu: EV_MENU
	open_button, parse_button,
	edit_button, save_button, tree_expand, tree_expand_one, tree_shrink_one, tree_technical_node: EV_BUTTON
	arch_desc_purpose_text,
	arch_desc_use_text, arch_desc_misuse_text, arch_desc_copyright_text, archetype_text_edit_area,
	parser_status_area: EV_TEXT
	arch_desc_auth_contrib_list, languages_list, terminologies_list,
	arch_desc_keywords_list: EV_LIST
	arch_notebook, source_notebook, ontology_notebook: EV_NOTEBOOK
	archetype_file_tree,
	parsed_archetype_tree: EV_TREE
	explorer_view_area: EV_HORIZONTAL_SPLIT_AREA
	total_view_area, info_view_area: EV_VERTICAL_SPLIT_AREA
	action_bar,
	author_lang_term_hbox, arch_desc_status_hbox, arch_desc_auth_hbox, arch_desc_contrib_hbox,
	l_ev_horizontal_box_1, lang_hbox, term_hbox, arch_desc_details_hbox, l_ev_horizontal_box_2,
	l_ev_horizontal_box_3, l_ev_horizontal_box_4, l_ev_horizontal_box_5, l_ev_horizontal_box_6,
	l_ev_horizontal_box_7, arch_desc_copyright_hbox, parsed_archetype_tree_view: EV_HORIZONTAL_BOX
	main,
	arch_desc_area_vbox, l_ev_vertical_box_1, l_ev_vertical_box_2, l_ev_vertical_box_3,
	tree_controls: EV_VERTICAL_BOX
	format_label, l_ev_label_1, language_label, arch_desc_status_label,
	arch_desc_auth_orig_auth_label, arch_desc_auth_contrib_label, languages_label, terminologies_label,
	arch_desc_purpose_label, arch_desc_use_label, arch_desc_misuse_label, arch_desc_keywords_label,
	arch_desc_resource_package_label, arch_desc_resource_orig_res_label, arch_desc_copyright_label: EV_LABEL
	open_adl_file_mi,
	save_adl_file_mi, exit_tool_mi, options, icon_help_mi, news, online_mi, about_mi: EV_MENU_ITEM
	menu: EV_MENU_BAR
	arch_desc_auth_frame,
	lang_term_frame, arch_desc_details_frame, arch_desc_resource_frame: EV_FRAME

feature {NONE} -- Implementation

	is_in_default_state: BOOLEAN is
			-- Is `Current' in its default state?
		do
			-- Re-implement if you wish to enable checking
			-- for `Current'.
			Result := True
		end
	
	user_initialization is
			-- Feature for custom initialization, called at end of `initialize'.
		deferred
		end
	
	open_adl_file is
			-- Called by `select_actions' of `open_adl_file_mi'.
		deferred
		end
	
	save_adl_file is
			-- Called by `select_actions' of `save_adl_file_mi'.
		deferred
		end
	
	exit_app is
			-- Called by `select_actions' of `exit_tool_mi'.
		deferred
		end
	
	set_options is
			-- Called by `select_actions' of `options'.
		deferred
		end
	
	display_icon_help is
			-- Called by `select_actions' of `icon_help_mi'.
		deferred
		end
	
	display_news is
			-- Called by `select_actions' of `news'.
		deferred
		end
	
	show_online_help is
			-- Called by `select_actions' of `online_mi'.
		deferred
		end
	
	display_about is
			-- Called by `select_actions' of `about_mi'.
		deferred
		end
	
	parse_archetype is
			-- Called by `select_actions' of `parse_button'.
		deferred
		end
	
	edit_archetype is
			-- Called by `select_actions' of `edit_button'.
		deferred
		end
	
	select_format is
			-- Called by `select_actions' of `format_combo'.
		deferred
		end
	
	select_language is
			-- Called by `select_actions' of `language_combo'.
		deferred
		end
	
	archetype_tree_item_select is
			-- Called by `select_actions' of `archetype_file_tree'.
		deferred
		end
	
	node_map_item_select is
			-- Called by `select_actions' of `parsed_archetype_tree'.
		deferred
		end
	
	expand_tree is
			-- Called by `select_actions' of `tree_expand'.
		deferred
		end
	
	expand_tree_one_level is
			-- Called by `select_actions' of `tree_expand_one'.
		deferred
		end
	
	shrink_tree_one_level is
			-- Called by `select_actions' of `tree_shrink_one'.
		deferred
		end
	
	tree_technical_mode is
			-- Called by `select_actions' of `tree_technical_node'.
		deferred
		end
	
	move_cursor_to_pointer_location (a_x, a_y, a_button: INTEGER; a_x_tilt, a_y_tilt, a_pressure: DOUBLE; a_screen_x, a_screen_y: INTEGER) is
			-- Called by `pointer_button_press_actions' of `archetype_text_edit_area'.
		deferred
		end
	
	pointer_double_click_action (a_x, a_y, a_button: INTEGER; a_x_tilt, a_y_tilt, a_pressure: DOUBLE; a_screen_x, a_screen_y: INTEGER) is
			-- Called by `pointer_double_press_actions' of `archetype_text_edit_area'.
		deferred
		end
	
	process_keystroke (a_keystring: STRING) is
			-- Called by `key_press_string_actions' of `archetype_text_edit_area'.
		deferred
		end
	

end -- class MAIN_WINDOW_IMP
