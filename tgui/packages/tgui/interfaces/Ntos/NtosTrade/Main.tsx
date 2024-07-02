import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui/components';

import {
  CartData,
  Data,
  GoodsData,
  MainData,
  OffersData,
  StationData,
  TradeScreens,
} from './data';

const MONEY_PREFIX = '';
const MONEY_AFFIX = 'cr';

const formatCurrency = (val: number) => {
  return `${MONEY_PREFIX}${val}${MONEY_AFFIX}`;
};

export const NtosTradeMain = (props: { main: MainData }) => {
  const { act, data } = useBackend<Data>();
  const { main } = props;

  const { account, tradescreen, station } = data;

  let content = <Box color="bad">Unknown state &quot;{tradescreen}&quot;</Box>;

  if (tradescreen === TradeScreens.Goods && main.goods) {
    if (!station) {
      return <Box color="average">Select a trade station.</Box>;
    }
    content = <TradeScreenGoods station={station} goods={main.goods} />;
  } else if (tradescreen === TradeScreens.Offers && main.offers) {
    if (!station) {
      return <Box color="average">Select a trade station.</Box>;
    }
    content = <TradeScreenOffers station={station} offers={main.offers} />;
  } else if (tradescreen === TradeScreens.Cart && main.cart) {
    content = <TradeScreenCart cart={main.cart} />;
  }

  return (
    <Section fill height="95%" align="center" style={{ borderRadius: '5px' }}>
      <Stack vertical pl={1} pr={1}>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Account Balance">
              {formatCurrency(account?.balance || 0)}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Tabs mb={-1} ml={0} mr={0}>
            <Tabs.Tab
              icon="tag"
              selected={tradescreen === TradeScreens.Goods}
              onClick={() =>
                act('trade_screen', { trade_screen: TradeScreens.Goods })
              }
            >
              Goods
            </Tabs.Tab>
            <Tabs.Tab
              icon="suitcase"
              selected={tradescreen === TradeScreens.Offers}
              onClick={() =>
                act('trade_screen', { trade_screen: TradeScreens.Offers })
              }
            >
              Offers
            </Tabs.Tab>
            <Tabs.Tab
              icon="shopping-cart"
              selected={tradescreen === TradeScreens.Cart}
              onClick={() =>
                act('trade_screen', { trade_screen: TradeScreens.Cart })
              }
            >
              View Cart
            </Tabs.Tab>
            <Tabs.Tab
              icon="cart-plus"
              selected={tradescreen === TradeScreens.Saved}
              onClick={() =>
                act('trade_screen', { trade_screen: TradeScreens.Saved })
              }
            >
              Saved Carts
            </Tabs.Tab>
            <Tabs.Tab
              icon="comment"
              selected={tradescreen === TradeScreens.Orders}
              onClick={() =>
                act('trade_screen', { trade_screen: TradeScreens.Orders })
              }
            >
              Order Requests
            </Tabs.Tab>
            <Tabs.Tab
              icon="scroll"
              selected={tradescreen === TradeScreens.Logs}
              onClick={() =>
                act('trade_screen', { trade_screen: TradeScreens.Logs })
              }
            >
              Logs
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>{content}</Stack.Item>
      </Stack>
    </Section>
  );
};

const StationInfo = (props: { station: StationData }) => {
  const { station } = props;

  return (
    <Section
      width="100%"
      backgroundColor="rgb(0, 0, 0)"
      style={{
        background:
          'linear-gradient(-90deg, rgba(0, 0, 0, 0.9) 0%, rgba(0, 0, 0, 0.9) 70%, rgba(0, 0, 0, 0) 90%), url(trading_background.png)',
        borderRadius: '5px',
      }}
    >
      <LabeledList>
        <LabeledList.Item label="Station" textAlign="center" color="label">
          {station.desc}
        </LabeledList.Item>
        <LabeledList.Item label="Favor">
          <ProgressBar value={station.favor} maxValue={station.favor_needed}>
            {station.favor} / {station.favor_needed}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Offer Time Remaining" textAlign="center">
          {station.offer_time}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TradeScreenGoods = (props: {
  station: StationData;
  goods: GoodsData;
}) => {
  const { act } = useBackend();
  const { station, goods } = props;

  return (
    <Section>
      <Stack align="flex-start" justify="space-around">
        <Stack.Item basis="70%">
          <StationInfo station={station} />
        </Stack.Item>
        <Stack.Item textAlign="left" verticalAlign="top">
          <Box bold textAlign="center">
            Cart
          </Box>
          <Button icon="money-bill-wave" fluid disabled={goods.total === 0}>
            Buy (${goods.total})
          </Button>
          <Button icon="undo" fluid>
            Reset
          </Button>
          <Button icon="shopping-cart" fluid>
            View Shopping Cart
          </Button>
        </Stack.Item>
      </Stack>
      <Section fill height={34} textAlign="left" mt={2}>
        <Stack vertical>
          <Stack.Item>
            {goods.categories.map((cat) => (
              <Button
                key={cat.index}
                icon="folder"
                selected={goods.category === cat.index}
                onClick={() =>
                  act('goods_category', { goods_category: cat.index })
                }
              >
                {cat.name}
              </Button>
            ))}
          </Stack.Item>
          <Stack.Item grow>
            {!goods.category ? (
              <Box color="bad">Please select a category.</Box>
            ) : (
              <Section fill height={32} style={{ overflowY: 'auto' }}>
                <Table mt={1}>
                  <Table.Row header style={{ borderBottom: '1px solid #aaf' }}>
                    <Table.Cell header>Name</Table.Cell>
                    <Table.Cell header>Price</Table.Cell>
                    <Table.Cell header>Available</Table.Cell>
                    <Table.Cell header>Cart</Table.Cell>
                    <Table.Cell header>Sell Price</Table.Cell>
                    <Table.Cell header>Sell</Table.Cell>
                  </Table.Row>
                  {goods.goods.map((good) => (
                    <Table.Row key={good.index}>
                      <Table.Cell>{good.name}</Table.Cell>
                      <Table.Cell>{formatCurrency(good.price)}</Table.Cell>
                      <Table.Cell>{good.amount_available}</Table.Cell>
                      <Table.Cell>
                        <Button
                          icon="minus"
                          onClick={() =>
                            act('cart_remove', { idx: good.index })
                          }
                          mt={0.5}
                        />
                        <Button
                          onClick={() =>
                            act('cart_add_input', { idx: good.index })
                          }
                        >
                          {good.count}
                        </Button>
                        <Button
                          icon="plus"
                          onClick={() => act('cart_add', { idx: good.index })}
                        />
                      </Table.Cell>
                      <Table.Cell>{formatCurrency(good.sell_price)}</Table.Cell>
                      <Table.Cell>
                        <Button icon="suitcase" />
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Section>
    </Section>
  );
};

const TradeScreenOffers = (props: {
  station: StationData;
  offers: OffersData;
}) => {
  const { station, offers } = props;
  return (
    <Section ml={1} textAlign="left">
      <StationInfo station={station} />
      <Section
        style={{ background: 'rgba(0, 0, 0, 0.2)', borderRadius: '5px' }}
        mr={1}
        p={1}
      >
        <Box>
          <Box fontSize={2} inline>
            Special Offers
          </Box>
          <Box fontSize={1.5} inline ml={2}>
            (Time Left: {station?.offer_time})
          </Box>
        </Box>
        <Section fill height={32} style={{ overflowY: 'auto' }}>
          <Table>
            <Table.Row header>
              <Table.Cell header>Name</Table.Cell>
              <Table.Cell header>Price</Table.Cell>
              <Table.Cell header>Amount</Table.Cell>
              <Table.Cell header collapsing>
                Send
              </Table.Cell>
            </Table.Row>
            {offers.map((offer) => (
              <Table.Row key={offer.index}>
                <Table.Cell>{offer.name}</Table.Cell>
                <Table.Cell>{formatCurrency(offer.price)}</Table.Cell>
                <Table.Cell>
                  {offer.available} / {offer.amount}
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Button icon="check" fontSize={0.9} mb={0.5} />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Section>
    </Section>
  );
};

const TradeScreenCart = (props: { cart: CartData }) => {
  const { act } = useBackend();
  const { cart } = props;

  return (
    <Section fill>
      <Stack fill textAlign="left">
        <Stack.Item grow mr={4}>
          <Section title="Cart">
            {!!cart.cart_stations && cart.cart_stations.length ? (
              <>
                <Tabs mb={-1}>
                  {cart.cart_stations.map((station) => (
                    <Tabs.Tab
                      key={station.index}
                      selected={cart.current_cart_station === station.index}
                      onClick={() =>
                        act('set_cart_station', { station: station.index })
                      }
                    >
                      {station.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
                <Divider />
              </>
            ) : (
              <Box color="bad">There are no goods in the cart.</Box>
            )}
            {!!cart.cart_categories && cart.cart_categories.length ? (
              <>
                <Tabs mt={-1.5} mb={-1}>
                  {cart.cart_categories.map((cat) => (
                    <Tabs.Tab
                      key={cat.index}
                      selected={cart.current_cart_category === cat.index}
                      onClick={() =>
                        act('set_cart_category', { cat: cat.index })
                      }
                    >
                      {cat.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
                <Divider />
              </>
            ) : null}
            {!!cart.cart_goods && cart.cart_goods.length ? (
              <Section mt={-1} fill height={35} style={{ overflowY: 'auto' }}>
                <Table>
                  <Table.Row header>
                    <Table.Cell header>Name</Table.Cell>
                    <Table.Cell header>Price</Table.Cell>
                    <Table.Cell header>Available in Station</Table.Cell>
                    <Table.Cell header textAlign="right">
                      Cart
                    </Table.Cell>
                  </Table.Row>
                  {cart.cart_goods.map((good) => (
                    <Table.Row key={good.index}>
                      <Table.Cell>{good.name}</Table.Cell>
                      <Table.Cell>{formatCurrency(good.price)}</Table.Cell>
                      <Table.Cell>{good.amount_available}</Table.Cell>
                      <Table.Cell textAlign="right">
                        <Button
                          icon="minus"
                          onClick={() =>
                            act('cart_remove', { idx: good.index })
                          }
                        />
                        <Button
                          onClick={() =>
                            act('cart_add_input', { idx: good.index })
                          }
                        >
                          {good.count}
                        </Button>
                        <Button
                          icon="plus"
                          onClick={() => act('cart_add', { idx: good.index })}
                        />
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            ) : null}
          </Section>
        </Stack.Item>
        <Stack.Item basis="20%">
          <Section title="Checkout">
            <Button fluid color="good" fontSize={1.25}>
              <Stack align="center" justify="space-between">
                <Stack.Item>
                  <Icon name="shopping-cart" />
                </Stack.Item>
                <Stack.Item>Buy Now</Stack.Item>
              </Stack>
            </Button>
            <Divider />
            <Stack align="center" justify="space-between" bold>
              <Stack.Item fontSize={1.5}>Order Total:</Stack.Item>
              <Stack.Item fontSize={1.5}>
                {formatCurrency(cart.total)}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
