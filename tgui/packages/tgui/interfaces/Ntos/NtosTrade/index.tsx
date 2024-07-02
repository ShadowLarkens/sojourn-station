import { useBackend } from 'tgui/backend';
import { Box, Stack } from 'tgui/components';
import { NtosWindow } from 'tgui/layouts';

import { Data } from './data';
import { NtosTradeHeader } from './Header';
import { NtosTradeMain } from './Main';
import { NtosTradeTree } from './Tree';

export const NtosTrade = (props) => {
  const { data } = useBackend<Data>();

  let content = <Box>State Error</Box>;
  if (data.prg_screen) {
    if (data.main) {
      content = <NtosTradeMain main={data.main} />;
    } else {
      content = <Box color="average">Please select a station.</Box>;
    }
  } else {
    if (data.tree) {
      content = <NtosTradeTree station={data.station} tree={data.tree} />;
    }
  }

  return (
    <NtosWindow width={1000} height={800}>
      <NtosWindow.Content height="100%">
        <Stack vertical height="100%">
          <Stack.Item>
            <NtosTradeHeader />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>{content}</Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
