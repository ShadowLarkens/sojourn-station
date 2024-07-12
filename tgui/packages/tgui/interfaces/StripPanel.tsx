import { Placement } from '@popperjs/core';
import { BooleanLike } from 'common/react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Icon, Image, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

type Slot = {
  slot_name: string;
  slot_id: number;
  thing: string | null;
  appearance: string | null;
};

type SpecialAction = {
  name: string;
  action: string;
  icon?: string | null;
  params?: { [key: string]: string } | null;
  selected?: BooleanLike;
};

type Data = {
  mob_name: string;
  slots: Slot[];
  special_actions: SpecialAction[];
  will_refresh: BooleanLike;
};

export const StripPanel = (props) => {
  return (
    <Window width={397} height={620}>
      <Window.Content>
        <PaperDoll />
      </Window.Content>
    </Window>
  );
};

enum SlotId {
  none = 0,
  back = 1,
  wear_mask = 2,
  handcuffed = 3,
  l_hand = 4,
  r_hand = 5,
  belt = 6,
  wear_id = 7,
  l_ear = 8,
  glasses = 9,
  gloves = 10,
  head = 11,
  shoes = 12,
  wear_suit = 13,
  w_uniform = 14,
  l_store = 15,
  r_store = 16,
  s_store = 17,
  in_backpack = 18,
  legcuffed = 19,
  r_ear = 20,
  legs = 21,
  accessory_buffer = 22,
}

/**
 * This maps slot IDs to left/top offsets
 */
const slotMap: {
  [key: number]: { position: number[]; tooltipPosition: Placement };
} = {
  // Head
  [SlotId.l_ear]: { position: [8, 5.5], tooltipPosition: 'bottom' },
  [SlotId.head]: { position: [13, -0.5], tooltipPosition: 'right' },
  [SlotId.r_ear]: { position: [18, 5.5], tooltipPosition: 'bottom' },
  [SlotId.glasses]: { position: [13, 3.8], tooltipPosition: 'bottom' },
  [SlotId.wear_mask]: { position: [13, 8.2], tooltipPosition: 'top' },
  // Hands
  [SlotId.r_hand]: { position: [-0.2, 11.5], tooltipPosition: 'right' },
  [SlotId.l_hand]: { position: [26.5, 11.5], tooltipPosition: 'left' },
  [SlotId.gloves]: { position: [23, 15.7], tooltipPosition: 'left' },
  // Shoes
  [SlotId.shoes]: { position: [13, 41.5], tooltipPosition: 'top' },
  // Body
  [SlotId.wear_id]: { position: [11.5, 13], tooltipPosition: 'bottom' },
  [SlotId.w_uniform]: { position: [10.5, 19], tooltipPosition: 'bottom' },
  [SlotId.wear_suit]: { position: [15.5, 19], tooltipPosition: 'bottom' },
  [SlotId.belt]: { position: [13, 24], tooltipPosition: 'top' },
  [SlotId.back]: { position: [24, 24], tooltipPosition: 'bottom' },
  [SlotId.s_store]: { position: [24, 29], tooltipPosition: 'bottom' },
  [SlotId.l_store]: { position: [16, 29], tooltipPosition: 'bottom' },
};

export const PaperDoll = (props) => {
  const { act, data } = useBackend<Data>();

  const { mob_name, slots, special_actions, will_refresh } = data;
  let all_actions = [
    ...special_actions,
    { name: 'Refresh', icon: 'sync', action: 'refresh' } as SpecialAction,
  ];

  return (
    <Section
      fill
      width={32}
      position="relative"
      pl={2}
      pt={2}
      pb={1}
      overflow="hidden"
    >
      <Box left={0} top={0} bold color="label" fontSize={1.2} width={11}>
        {mob_name}
      </Box>
      {!!will_refresh && (
        <Box position="absolute" right={1} top={0}>
          <Icon name="spinner" spin size={3} />
        </Box>
      )}
      <Stack
        width={9}
        left={0}
        top={21}
        position="absolute"
        align="center"
        justify="center"
        vertical
      >
        {all_actions
          .filter((a) => a !== null && a !== undefined)
          .map((action) => (
            <Stack.Item key={action.name} width={9} basis="auto">
              <Button
                fluid
                textAlign="center"
                selected={action.selected}
                icon={action.icon || ''}
                style={{ zIndex: '1', whiteSpace: 'normal' }}
                onClick={() => act(action.action, action.params || {})}
              >
                {action.name}
              </Button>
            </Stack.Item>
          ))}
      </Stack>
      <Box
        className="PaperDoll--Background"
        height={42}
        width={39}
        position="absolute"
        left={-4.5}
        top={4}
      />
      {slots
        ? slots.map((slot) => {
            let data = slotMap[slot.slot_id] || {
              position: [0, 0],
              tooltipPosition: 'bottom',
            };
            return (
              <Button
                key={slot.slot_id}
                width={4}
                height={4}
                className="PaperDoll--Slot"
                backgroundColor="transparent"
                position="absolute"
                left={data.position[0]}
                top={data.position[1]}
                align="center"
                verticalAlignContent="middle"
                tooltipPosition={data.tooltipPosition}
                pl={0}
                pr={0}
                tooltip={
                  slot.slot_name + (slot.thing ? ' - ' + slot.thing : '')
                }
                style={{ zIndex: '1' }}
                onClick={() => act('strip', { id: slot.slot_id })}
              >
                {slot.appearance ? (
                  <Image src={slot.appearance} fixErrors />
                ) : slot.thing ? (
                  <Icon
                    m={0}
                    name="exclamation-triangle"
                    size={2}
                    color="average"
                  />
                ) : slot.slot_id === SlotId.l_store ? (
                  <Icon m={0} name="question" size={2} />
                ) : null}
              </Button>
            );
          })
        : null}
    </Section>
  );
};
