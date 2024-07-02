#define GOODS_SCREEN "goods"
#define OFFER_SCREEN "offers"
#define CART_SCREEN "cart"
#define ORDER_SCREEN "orders"
#define SAVED_SCREEN "saved"
#define LOG_SCREEN "logs"
#define LOG_SHIPPING "Shipping"
#define LOG_EXPORT "Export"
#define LOG_OFFER "Offer"
#define LOG_SALE "Sale"
#define LOG_ORDER "Order"
#define PRG_MAIN TRUE
#define PRG_TREE FALSE
#define TRADESCREEN list(GOODS_SCREEN, OFFER_SCREEN, CART_SCREEN, ORDERS_SCREEN, SAVED_SCREEN)
#define LOG_SCREEN_LIST list(LOG_SHIPPING, LOG_EXPORT, LOG_OFFER, LOG_ORDER)

/datum/tgui_module/trade
	name = "Trading Program"
	tgui_id = "Trade"
	ntos = TRUE

/datum/tgui_module/trade/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/trade),
		get_asset_datum(/datum/asset/spritesheet_batched/trade)
	)

/datum/tgui_module/trade/ui_data()
	. = ..()
	var/datum/computer_file/program/trade/PRG = host // not ui_host(), that would be our computer
	if(!istype(PRG))
		return

	var/is_all_access = FALSE		// Used for log and order access
	var/account

	.["prg_type"] = PRG.program_type

	.["prg_screen"] = PRG.prg_screen
	.["tradescreen"] = PRG.trade_screen
	.["log_screen"] = PRG.log_screen

	if(PRG.station)
		.["station"] = list(
			"name" = PRG.station.name,
			"desc" = PRG.station.desc,
			"id" = PRG.station.uid,
			"index" = SStrade.discovered_stations.Find(PRG.station),
			"favor" = PRG.station.favor,
			"favor_needed" = max(PRG.station.hidden_inv_threshold, PRG.station.recommendation_threshold),
			"recommendations_needed" = PRG.station.recommendations_needed,
			"offer_time" = time2text((PRG.station.update_time - (world.time - PRG.station.update_timer_start)), "mm:ss")
		)
	else
		.["station"] = null


	if(!QDELETED(PRG.sending))
		.["sending"] = list(
			"id" = PRG.sending.get_id(),
			"index" = SStrade.beacons_sending.Find(PRG.sending),
			"time_max" = round(PRG.sending.export_cooldown / (1 SECOND)),
			"time_start" = PRG.sending.export_timer_start,
			"time_elapsed" = PRG.sending.export_timer_start ? round((world.time - PRG.sending.export_timer_start) / (1 SECOND)) : 0,
			"ready" = PRG.sending.export_timer_start ? FALSE : TRUE
		)
	else
		.["sending"] = null

	if(PRG.account)
		account = "[PRG.account.get_name()] #[PRG.account.account_number]"
		.["account"] = list(
			"name" = account,
			"balance" = PRG.account.money
		)
		var/dept_id = PRG.account.department_id
		if(dept_id)
			is_all_access = (dept_id == DEPARTMENT_LSS) ? TRUE : FALSE
	else
		.["account"] = null
		is_all_access = FALSE

	.["is_all_access"] = is_all_access

	if(!QDELETED(PRG.receiving))
		.["receiving"] = list(
			"id" = PRG.receiving.get_id(),
			"index" = SStrade.beacons_receiving.Find(PRG.receiving),
		)
	else
		.["receiving"] = null

	if(PRG.prg_screen == PRG_TREE)
		var/list/line_list = list()
		var/list/trade_tree = list()

		for(var/station in SStrade.all_stations)
			var/datum/trade_station/TS = station
			var/is_discovered = (locate(TS) in SStrade.discovered_stations) ? TRUE : FALSE
			var/ts_tree_x = round(TS.tree_x*100)
			var/ts_tree_y = round(TS.tree_y*100)
			var/list/trade_tree_data = list(
				"id" =				"[TS.uid]",
				"name" =			"[TS.name]",
				"description" =		"[TS.desc]",
				"is_discovered" =	is_discovered,
				"x" =				ts_tree_x,
				"y" =				ts_tree_y,
				"icon" =			"[TS.icon_states[2 - is_discovered]]"
			)
			LAZYADD(trade_tree, list(trade_tree_data))

			if(LAZYLEN(TS.stations_recommended))
				for(var/id in TS.stations_recommended)
					if(!istext(id))
						break
					var/datum/trade_station/RS = SStrade.get_station_by_uid(id)
					if(RS)
						var/rs_tree_x = round(RS.tree_x*100)
						var/rs_tree_y = round(RS.tree_y*100)
						var/line_x = (min(rs_tree_x, ts_tree_x))
						var/line_y = (min(rs_tree_y, ts_tree_y))
						var/width = (abs(rs_tree_x - ts_tree_x))
						var/height = (abs(rs_tree_y - ts_tree_y))

						var/istop = FALSE
						if(rs_tree_y > ts_tree_y)
							istop = TRUE
						var/isright = FALSE
						if(rs_tree_x < ts_tree_x)
							isright = TRUE

						var/list/line_data = list(
							"line_x" =           line_x,
							"line_y" =           line_y,
							"width" =            width,
							"height" =           height,
							"istop" =            istop,
							"isright" =          isright,
						)
						LAZYADD(line_list, list(line_data))

		.["tree"] = list(
			"trade_tree" = trade_tree,
			"tree_lines" = line_list,
		)
	else
		.["tree"] = null

	if(PRG.prg_screen == PRG_MAIN)
		if(!PRG.station)
			.["main"] = null
			return

		.["main"] = list(
			"goods" = null,
			"offers" = null,
			"cart" = null,
			"order" = null,
			"saved" = null,
			"log" = null,
		)

		if(PRG.trade_screen == GOODS_SCREEN)
			if(!PRG.chosen_category || !(PRG.chosen_category in PRG.station.inventory))
				PRG.set_chosen_category()
			.["main"]["goods"] = list(
				"category" = PRG.chosen_category ? PRG.station.inventory.Find(PRG.chosen_category) : null,
				"goods" = list(),
				"categories" = list(),
				"total" = SStrade.collect_price_for_list(PRG.shoppinglist),
			)
			for(var/i in PRG.station.inventory)
				if(istext(i))
					.["main"]["goods"]["categories"] += list(list("name" = i, "index" = PRG.station.inventory.Find(i)))

			if(PRG.chosen_category)
				var/list/assort = PRG.station.inventory[PRG.chosen_category]
				if(islist(assort))
					for(var/path in assort)
						if(!ispath(path, /atom/movable))
							continue
						var/atom/movable/AM = path

						var/index = assort.Find(path)

						var/amount = PRG.station.get_good_amount(PRG.chosen_category, index)

						var/pathname = initial(AM.name)

						var/list/good_packet = assort[path]
						if(islist(good_packet))
							pathname = good_packet["name"] ? good_packet["name"] : pathname
						var/price = SStrade.get_import_cost(path, PRG.station)
						var/sell_price = SStrade.get_sell_price(path, PRG.station, price)

						var/amount2sell = 0
						if(PRG.station && PRG.sending)
							amount2sell = length(SStrade.assess_offer(PRG.sending, path))

						var/list/shop_list_station = PRG.shoppinglist[PRG.station]
						var/count = 0
						if(shop_list_station)
							var/list/shop_list_category = list()
							if(shop_list_station.Find(PRG.chosen_category))
								shop_list_category = shop_list_station[PRG.chosen_category]
								if(shop_list_category.Find(path))
									count = shop_list_category[path]

						var/isblacklisted = ispath(path, /obj/item/storage)

						.["main"]["goods"]["goods"] += list(list(
							"name" = pathname,
							"price" = price,
							"count" = count ? count : 0,
							"amount_available" = amount,
							"index" = index,
							"sell_price" = sell_price,
							"isblacklisted" = isblacklisted,
							"amount_available_around" = amount2sell
						))

		if(PRG.trade_screen == OFFER_SCREEN)
			.["main"]["offers"] = list()
			for(var/offer_path in PRG.station.special_offers)
				var/path = offer_path
				var/list/offer_content = PRG.station.special_offers[offer_path]
				var/list/offer = list(
					"station" = PRG.station.name,
					"name" = offer_content["name"],
					"amount" = offer_content["amount"],
					"price" = offer_content["price"],
					"index" = SStrade.discovered_stations.Find(PRG.station),
					"path" = path,
					"available" = null,
				)
				if(PRG.sending)
					offer["available"] = length(SStrade.assess_offer(PRG.sending, offer_path, offer_content["attachments"], offer_content["attach_count"]))
				.["main"]["offers"] += list(offer)

		if(PRG.trade_screen == CART_SCREEN)
			.["main"]["cart"] = list(
				"current_cart_station" = PRG.cart_station_index,
				"current_cart_category" = PRG.cart_category_index,
				"cart_stations" = list(),
				"cart_categories" = list(),
				"cart_goods" = list(),
				"total" = SStrade.collect_price_for_list(PRG.shoppinglist),
			)
			for(var/datum/trade_station/TS in PRG.shoppinglist)
				.["main"]["cart"]["cart_stations"] += list(list("name" = TS.name, "index" = PRG.shoppinglist.Find(TS)))
			if(PRG.cart_station_index)
				PRG.station = PRG.shoppinglist[PRG.cart_station_index]
				var/list/categories = PRG.shoppinglist[PRG.station]
				for(var/category in categories)
					.["main"]["cart"]["cart_categories"] += list(list("name" = category, "index" = categories.Find(category)))
				if(PRG.cart_category_index)
					PRG.chosen_category = categories[PRG.cart_category_index]
					var/list/goods = categories[PRG.chosen_category]
					for(var/path in goods)
						if(!ispath(path, /atom/movable))
							continue
						var/atom/movable/AM = path

						var/list/inventory = PRG.station.inventory[PRG.chosen_category]
						var/index = inventory.Find(path)
						var/amount = PRG.station.get_good_amount(PRG.chosen_category, index)

						var/pathname = initial(AM.name)

						var/list/good_packet = goods[path]
						if(islist(good_packet))
							pathname = good_packet["name"] ? good_packet["name"] : pathname
						var/price = SStrade.get_import_cost(path, PRG.station)

						var/count = goods[path]

						.["main"]["cart"]["cart_goods"] += list(list(
							"name" = pathname,
							"price" = price,
							"count" = count ? count : 0,
							"amount_available" = amount,
							"index" = index,
						))

		if(PRG.trade_screen == ORDER_SCREEN)
			if(!SStrade.order_queue.Find(PRG.current_order))		// If the order was removed from the queue by someone else (guild/lonestar or hacker),
				PRG.current_order = null							// clear the current order. Else we get a window of undefined values

			var/list/current_orders = list()

			.["main"]["order"] = list(
				"current_order" = PRG.current_order,
				"order_page" = PRG.current_order_page,
				"requesting_acct" = null,
				"reason" = null,
				"order_cost" = null,
				"handling_fee" = null,
				"order_contents" = null,
				"page_max" = null,
				"order_data" = null,
			)

			for(var/order in SStrade.order_queue)
				var/list/order_data = SStrade.order_queue[order]
				var/datum/money_account/requesting_account = order_data["requesting_acct"]

				// Check if the request is the one we want to view
				if(order == PRG.current_order)
					.["main"]["order"]["requesting_acct"] = "[requesting_account.get_name()] #[requesting_account.account_number]"
					.["main"]["order"]["reason"] = order_data["reason"]
					.["main"]["order"]["order_cost"] = order_data["cost"]
					.["main"]["order"]["handling_fee"] = order_data["fee"]
					.["main"]["order"]["order_contents"] = order_data["viewable_contents"]

				// Store values for the request list
				current_orders += list(list(
					"id" = order,
					"requesting_acct" = "[requesting_account.get_name()] #[requesting_account.account_number]",
					"reason" = order_data["reason"],
					"order_cost" = order_data["cost"],
					"handling_fee" = order_data["fee"],
					"order_contents" = order_data["viewable_contents"]
				))

			// If not the master account, only show the requests from the linked account
			if(!is_all_access)
				for(var/request in current_orders)
					var/list/request_data = request
					if(request_data["requesting_acct"] != account)
						current_orders -= list(request)

			// Page building logic
			var/orders_per_page = 10
			var/orders_to_display = orders_per_page
			PRG.order_page_max = round(current_orders.len / orders_per_page, 1)
			var/page_remainder = current_orders.len % orders_per_page
			if(current_orders.len < orders_per_page * PRG.current_order_page)
				orders_to_display = page_remainder
			if(page_remainder < orders_per_page / 2)
				++PRG.order_page_max

			.["main"]["order"]["page_max"] = PRG.order_page_max ? PRG.order_page_max : 1

			var/list/page_of_orders = list()

			if(orders_to_display)
				for(var/i in 1 to orders_to_display)
					page_of_orders += list(current_orders[i + (orders_per_page * (PRG.current_order_page - 1))])

			.["main"]["order"]["order_data"] = page_of_orders

		if(PRG.trade_screen == SAVED_SCREEN)
			var/list/saved_carts = list()

			.["main"]["saved"] = list(
				"cart_page" = PRG.saved_cart_page,
				"page_max" = null,
				"saved_carts" = null,
			)

			for(var/list_name in PRG.saved_shopping_lists)
				saved_carts += list(list(
					"name" = list_name,
					"index" = PRG.saved_shopping_lists.Find(list_name)
				))

			// Page building logic
			var/carts_per_page = 10
			var/carts_to_display = carts_per_page
			PRG.saved_cart_page_max = round(saved_carts.len / carts_per_page, 1)
			var/page_remainder = saved_carts.len % carts_per_page
			if(saved_carts.len < carts_per_page * PRG.saved_cart_page)
				carts_to_display = page_remainder
			if(page_remainder < carts_per_page / 2)
				++PRG.saved_cart_page_max

			.["main"]["saved"]["page_max"] = PRG.saved_cart_page_max ? PRG.saved_cart_page_max : 1

			var/list/page_of_carts = list()

			if(carts_to_display)
				for(var/i in 1 to carts_to_display)
					page_of_carts += list(saved_carts[i + (carts_per_page * (PRG.saved_cart_page - 1))])

			.["main"]["saved"]["saved_carts"] = page_of_carts

		if(PRG.trade_screen == LOG_SCREEN)
			var/list/current_log = list()

			.["main"]["log"] = list(
				"log_page" = PRG.current_log_page,
				"log_page_max" = null,
				"current_log_data" = null,
			)

			switch(PRG.log_screen)
				if(LOG_SHIPPING)
					current_log = SStrade.shipping_log
				if(LOG_EXPORT)
					current_log = SStrade.export_log
				if(LOG_OFFER)
					current_log = SStrade.offer_log
				if(LOG_ORDER)
					current_log = SStrade.order_log
				else
					current_log = list()

			if(!is_all_access)
				var/list/sanitized_log = list()
				for(var/log_entry in current_log)
					var/list/log_data = log_entry
					if(log_data["ordering_acct"] == PRG.account.get_name())
						sanitized_log |= list(log_data)
				current_log = sanitized_log

			var/logs_per_page = 10
			var/logs_to_display = logs_per_page
			PRG.log_page_max = round(current_log.len / logs_per_page, 1)
			var/page_remainder = current_log.len % logs_per_page
			if(current_log.len < logs_per_page * PRG.current_log_page)
				logs_to_display = page_remainder
			if(page_remainder < logs_per_page / 2)
				++PRG.log_page_max

			.["main"]["log"]["log_page_max"] = PRG.log_page_max ? PRG.log_page_max : 1

			var/list/page_of_logs = list()

			if(logs_to_display)
				for(var/i in 1 to logs_to_display)
					page_of_logs += list(current_log[i + (logs_per_page * (PRG.current_log_page - 1))])

			.["main"]["log"]["current_log_data"] = page_of_logs
	else
		.["main"] = null


/datum/tgui_module/trade/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/computer_file/program/trade/PRG = host // not ui_host(), that would be our computer
	if(!istype(PRG))
		return

	switch(action)
		if("prg_screen")
			PRG.prg_screen = !PRG.prg_screen
			. = TRUE

		if("trade_screen")
			PRG.trade_screen = params["trade_screen"]
			. = TRUE

		if("log_screen")
			PRG.log_screen = input("Select log type", "Log Type", null) as null|anything in LOG_SCREEN_LIST
			PRG.current_log_page = 1
			. = TRUE

		if("goods_category")
			if(!PRG.chosen_category || !(PRG.chosen_category in PRG.station.inventory))
				PRG.set_chosen_category()
			PRG.set_chosen_category((text2num(params["goods_category"]) <= length(PRG.station.inventory)) ? PRG.station.inventory[text2num(params["goods_category"])] : "")
			. = TRUE

		if("set_account")
			var/acc_num = tgui_input_number(usr, "Enter account number", "Account linking", PRG.computer?.card_slot?.stored_card?.associated_account_number, 1000000)
			if(!acc_num)
				return

			var/acc_pin = tgui_input_number(usr, "Enter PIN", "Account linking", null, 1000000)
			if(!acc_pin)
				return

			var/card_check = PRG.computer?.card_slot?.stored_card?.associated_account_number == acc_num
			var/datum/money_account/A = attempt_account_access(acc_num, acc_pin, card_check ? 2 : 1, TRUE)
			if(!A)
				to_chat(usr, SPAN_WARNING("Unable to link account: access denied."))
				return

			PRG.account = A
			. = TRUE

		if("clear_account")
			PRG.account = null
			. = TRUE

		if("set_station")
			var/id = params["id"]
			var/datum/trade_station/S = SStrade.get_discovered_station_by_uid(id)
			if(!S)
				return TRUE
			PRG.set_chosen_category()
			PRG.station = S
			. = TRUE

		if("set_receiving")
			if(PRG.program_type != "master")
				return TRUE
			var/list/beacons_by_id = list()
			for(var/obj/machinery/trade_beacon/receiving/beacon in SStrade.beacons_receiving)
				if(get_area(beacon) == get_area(PRG.computer))
					var/beacon_id = beacon.get_id()
					beacons_by_id.Insert(beacon_id, beacon_id)
					beacons_by_id[beacon_id] = beacon
			if(beacons_by_id.len == 1)
				PRG.receiving = beacons_by_id[beacons_by_id[1]]
			else
				var/id = tgui_input_list(usr, "Select nearby receiving beacon", "Receiving Beacon", beacons_by_id, null)
				PRG.receiving = beacons_by_id[id]
			. = TRUE

		if("set_sending")
			if(PRG.program_type != "master")
				return TRUE
			var/list/beacons_by_id = list()
			for(var/obj/machinery/trade_beacon/sending/beacon in SStrade.beacons_sending)
				if(get_area(beacon) == get_area(PRG.computer))
					var/beacon_id = beacon.get_id()
					beacons_by_id.Insert(beacon_id, beacon_id)
					beacons_by_id[beacon_id] = beacon
			if(beacons_by_id.len == 1)
				PRG.sending = beacons_by_id[beacons_by_id[1]]
			else
				var/id = tgui_input_list(usr, "Select nearby sending beacon", "Sending Beacon", beacons_by_id, null)
				PRG.sending = beacons_by_id[id]
			. = TRUE

		if("export")
			if(!PRG.sending)
				return
			if(get_area(PRG.sending) != get_area(PRG.computer))
				to_chat(usr, SPAN_WARNING("ERROR: Sending beacon is too far from [PRG.computer]."))
				return
			SStrade.export(PRG.sending, PRG.account)
			. = TRUE

		if("offer_fulfill_all")
			if(!PRG.account)
				return
			if(get_area(PRG.sending) != get_area(PRG.computer))
				to_chat(usr, SPAN_WARNING("ERROR: Sending beacon is too far from [PRG.computer]."))
				return
			var/is_slaved = (PRG.program_type == "slave") ? TRUE : FALSE
			SStrade.fulfill_all_offers(PRG.sending, PRG.account, is_slaved)
			. = TRUE

		if("set_cart_station")
			PRG.cart_station_index = text2num(params["station"])
			PRG.cart_category_index = null
			. = TRUE

		if("set_cart_category")
			PRG.cart_category_index = text2num(params["cat"])
			. = TRUE

		if("cart_add")
			if(!account)
				to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
				return
			var/ind = text2num(params["idx"])
			var/list/category = PRG.station.inventory[PRG.chosen_category]
			if(!islist(category))
				return
			var/path = LAZYACCESS(category, ind)
			if(!path)
				return
			var/good_amount = PRG.station.get_good_amount(PRG.chosen_category, ind)
			if(!good_amount)
				return

			PRG.add_to_shop_list(path, 1, good_amount)
			return TRUE
		
		if("cart_add_input")
			if(!account)
				to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
				return
			var/ind = params["idx"]
			var/count2buy = tgui_input_number(user, "Input how many you want to add", "Trade", 2)
			if(count2buy < 1)
				return
			var/list/category = PRG.station.inventory[PRG.chosen_category]
			if(!islist(category))
				return
			var/path = LAZYACCESS(category, ind)
			if(!path)
				return
			var/good_amount = PRG.station.get_good_amount(PRG.chosen_category, ind)
			if(!good_amount)
				return

			PRG.add_to_shop_list(path, count2buy, good_amount)
			return TRUE

		if("cart_remove")
			if(!account)
				to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
				return
			var/list/category = PRG.station.inventory[PRG.chosen_category]
			if(!islist(category))
				return
			var/path = LAZYACCESS(category, text2num(params["idx"]))
			if(!path)
				return

			PRG.remove_from_shop_list(path, 1)
			return TRUE

#undef LOG_SCREEN_LIST
#undef TRADESCREEN
#undef PRG_TREE
#undef PRG_MAIN
#undef LOG_ORDER
#undef LOG_SALE
#undef LOG_OFFER
#undef LOG_EXPORT
#undef LOG_SHIPPING
#undef LOG_SCREEN
#undef SAVED_SCREEN
#undef ORDER_SCREEN
#undef CART_SCREEN
#undef OFFER_SCREEN
#undef GOODS_SCREEN
