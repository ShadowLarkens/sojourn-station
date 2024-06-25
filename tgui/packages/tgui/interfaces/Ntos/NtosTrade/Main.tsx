import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui/components';

import { Data, GoodsData, MainData, StationData, TradeScreens } from './data';

export const NtosTradeMain = (props: { main: MainData }) => {
  const { act, data } = useBackend<Data>();
  const { main } = props;

  const { account, tradescreen, station } = data;

  let content = <Box color="bad">Unknown state &quot;{tradescreen}&quot;</Box>;

  if (tradescreen === TradeScreens.Goods && main.goods) {
    content = <TradeScreenGoods station={station} goods={main.goods} />;
  } else if (tradescreen === TradeScreens.Offers) {
    content = (
      <Stack vertical align="center">
        <Stack.Item mt={1}>
          {!!station && <StationInfo station={station} />}
        </Stack.Item>
        <Stack.Item grow>
          <TradeScreenOffers />
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Section fill height="95%" align="center">
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Account Balance">
              {account?.balance || '0'} credits
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Tabs mb={-1}>
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
      width={50}
      backgroundColor="rgb(0, 0, 0)"
      style={{ borderRadius: '5px' }}
    >
      <LabeledList>
        <LabeledList.Item label="Station" textAlign="center" color="average">
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
  station: StationData | null;
  goods: GoodsData;
}) => {
  const { act } = useBackend();
  const { station, goods } = props;

  if (!station) {
    return <Section color="bad">Select a trade station.</Section>;
  }

  return (
    <Stack vertical align="center">
      <Stack.Item mt={1}>
        <Stack align="center">
          <Stack.Item>
            {!!station && <StationInfo station={station} />}
          </Stack.Item>
          <Stack.Item ml={5} textAlign="left" verticalAlign="top">
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
      </Stack.Item>
      <Stack.Item grow width="100%" mt={2}>
        <Section
          fill
          height={34}
          style={{
            background:
              'linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url(trading_background.png)',
            backgroundSize: 'cover',
            borderRadius: '5px',
          }}
          textAlign="left"
          pl={2}
          pr={2}
          pt={2}
          ml={0.2}
          mr={0.2}
          mt={0.2}
        >
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
                <Section fill height={28} style={{ overflowY: 'auto' }}>
                  <Table mt={1}>
                    <Table.Row
                      header
                      style={{ borderBottom: '1px solid #aaf' }}
                    >
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
                        <Table.Cell>{good.price}</Table.Cell>
                        <Table.Cell>{good.amount_available}</Table.Cell>
                        <Table.Cell>
                          <Button icon="plus" mt={0.5} />
                          <Button>0</Button>
                          <Button icon="minus" />
                        </Table.Cell>
                        <Table.Cell>{good.sell_price}</Table.Cell>
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
      </Stack.Item>
    </Stack>
  );
};

const TradeScreenOffers = (props) => {
  return <Section>Meow</Section>;
};
