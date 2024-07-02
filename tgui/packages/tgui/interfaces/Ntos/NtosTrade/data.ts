import { BooleanLike } from "common/react";

export type StationData = {
  name: string;
  desc: string;
  id: string;
  index: number;
  favor: number;
  favor_needed: number;
  recommendations_needed: number;
  offer_time: string;
};

export type SendingData = {
  id: string;
  index: number;
  time_max: number;
  time_start: number;
  time_elapsed: number;
  ready: BooleanLike;
};

export type AccountData = {
  name: string;
  balance: number;
};

export type ReceivingData = {
  id: string;
  index: number;
};

export type TradeTreeEntry = {
  id: string;
  name: string;
  description: string;
  is_discovered: BooleanLike;
  x: number;
  y: number;
  icon: string;
};

export type TreeLine = {
  line_x: number;
  line_y: number;
  width: number;
  height: number;
  istop: BooleanLike;
  isright: BooleanLike;
};

export type TreeData = {
  trade_tree: TradeTreeEntry[];
  tree_lines: TreeLine[];
};

export type Good = {
  name: string;
  price: number;
  count: number;
  amount_available: number;
  index: number;
  sell_price: number;
  isblacklisted: BooleanLike;
  amount_available_around: number;
};

export type Category = {
  name: string;
  index: number;
};

export type GoodsData = {
  category: number;
  goods: Good[];
  categories: Category[];
  total: number;
};

export type Offer = {
  station: string;
  name: string;
  amount: number;
  price: number;
  index: number;
  path: string;
  available: number | null;
};

export type OffersData = Offer[];

export type Station = {
  name: string;
  index: number;
};

export type CartData = {
  current_cart_station: number;
  current_cart_category: number;
  cart_stations: Station[];
  cart_categories: Category[];
  cart_goods: Pick<
    Good,
    'name' | 'price' | 'count' | 'amount_available' | 'index'
  >[];
  total: number;
};

export type Order = {
  id: string;
  requesting_acct: string;
  reason: string;
  order_cost: number;
  handling_fee: number;
  order_contents: string;
};

export type OrderData = {
  current_order: string;
  order_page: number;
  requesting_acct: string | null;
  reason: string | null;
  order_cost: number | null;
  handling_fee: number | null;
  order_contents: string | null;
  page_max: number | null;
  order_data: Order[] | null;
};

export type SavedCart = {
  name: string;
  index: string;
};

export type SavedData = {
  cart_page: number;
  page_max: number | null;
  saved_carts: SavedCart[] | null;
};

export type LogData = {
  log_page: number;
  log_page_max: number | null;
  current_log_data: string[] | null;
};

export type MainData = {
  goods: GoodsData | null;
  offers: OffersData | null;
  cart: CartData | null;
  order: OrderData | null;
  saved: SavedData | null;
  log: LogData | null;
};

export enum TradeScreens {
  Goods = "goods",
  Offers = "offers",
  Cart = "cart",
  Orders = "orders",
  Saved = "saved",
  Logs = "logs"
}

export type Data = {
  prg_type: string;
  prg_screen: BooleanLike;
  tradescreen: TradeScreens;
  log_screen: string;
  station: StationData | null;
  sending: SendingData | null;
  account: AccountData | null;
  is_all_access: BooleanLike;
  receiving: ReceivingData | null;
  tree: TreeData | null;
  main: MainData | null;
};
