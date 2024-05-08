import { BooleanLike } from '../../../common/react';
import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';


type Item = {
  name: string
  type: string
  [key: string]: any
}

type Category = {
  name: string
  type: string
  items: {
    [key: string]: Item
  }
}

type Data = {
  categories: { name: string; ref: string, type: string }[]
  selected_category: Category
}

export const CharacterSetup = props => {
  const { act, data } = useBackend<Data>();

  const { categories, selected_category } = data;

  let selected_category_data = categories.find((val) => val.type === selected_category.type);

  return (
    <Window width={1200} height={800}>
      <Window.Content>
        <ServerPreferencesFetcher render={(data) => {
          return (
            <>
              <Tabs>
                {categories.map(category => (
                  <Tabs.Tab
                    key={category.ref}
                    selected={selected_category.name === category.name}
                    onClick={() => act('set_category', { ref: category.ref })}
                  >
                    {category.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
              <DynamicCategory type={selected_category.type} static_data={selected_category_data} />
            </>
          )
        }} />
      </Window.Content>
    </Window>
  );
};

const DynamicCategory = (props: { type: string, static_data: any }) => {
  const { act } = useBackend();

  const { type } = props;

  switch (type) {
    case "/datum/category_group/player_setup_category/global_preferences":
      return <GlobalSettings />;
    case "/datum/category_group/player_setup_category/physical_preferences":
      return <PhysicalSettings />;
  }
};

const GlobalSettings = props => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title="Global Settings">
      <Stack fill>
        <Stack.Item grow m={2}>
          <UISettings data={data.selected_category.items["UI"] as unknown as UIData} />
          <PrefixSettings data={data.selected_category.items["Prefixes"] as unknown as PrefixData} />
        </Stack.Item>
        <Stack.Item grow m={2}>
          <DatumPreferences />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type UIData = {
  UI_style: string;
  UI_style_color: string;
  UI_style_alpha: number;
  ooccolor: string;
  clientfps: number;
  TGUI_theme: string;
}

const UISettings = (props: { data: UIData }) => {
  const { act } = useBackend<Data>();

  const { UI_style, UI_style_color, UI_style_alpha, ooccolor, clientfps, TGUI_theme } = props.data;

  return (
    <Section title="UI Settings">
      <LabeledList>
        <LabeledList.Item label="UI Style">
          {UI_style}
        </LabeledList.Item>
        <LabeledList.Item label="UI Color">
          {UI_style_color}
        </LabeledList.Item>
        <LabeledList.Item label="UI Alpha">
          {UI_style_alpha}
        </LabeledList.Item>
        <LabeledList.Item label="OOC Color">
          {ooccolor}
        </LabeledList.Item>
        <LabeledList.Item label="Client FPS">
          {clientfps}
        </LabeledList.Item>
        <LabeledList.Item label="TGUI Default Theme">
          {TGUI_theme}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

type PrefixData = {
  prefixes: {
    name: string,
    key: string,
    locked: BooleanLike,
    default: string
  }[]
}

const PrefixSettings = (props: { data: PrefixData }) => {
  const { act } = useBackend<Data>();

  const { prefixes } = props.data;

  return (
    <Section title="Prefix Keys">
      <Stack vertical fill zebra>
        {prefixes.map((prefix) => (<Stack.Item key={prefix.name}>
          <Stack align="center" p={1}>
            <Stack.Item grow textColor="#e8e8e8">
              {prefix.name}
            </Stack.Item>

            <Stack.Item grow>
              <Button fluid textAlign="center">
                {prefix.key}
              </Button>
            </Stack.Item>
          </Stack>
                                   </Stack.Item>))}
      </Stack>
    </Section>
  );
};

const DatumPreferences = props => {
  return (
    <Section title="Preferences">
      Meow
    </Section>
  );
};


const PhysicalSettings = props => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title="Physical Preferences">
      <img src="previewicon.png" />
    </Section>
  )

}