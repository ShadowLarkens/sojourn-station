import { classes } from 'common/react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Stack } from 'tgui/components';

import { StationData, TreeData } from './data';

export const NtosTradeTree = (props: {
  station: StationData | null;
  tree: TreeData;
}) => {
  const { act } = useBackend();
  const { station, tree } = props;
  return (
    <Section width="100%" height="590px" fill>
      <Stack height="100%">
        <Stack.Item
          basis="75%"
          position="relative"
          style={{
            background:
              'linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(trading_background.png)',
            backgroundSize: 'cover',
            borderRadius: '5px',
          }}
        >
          {tree.tree_lines.map((line) => (
            <Box
              key={line.line_x + line.line_y}
              position="absolute"
              width={line.width + '%'}
              height={line.height + '%'}
              left={line.line_x + '%'}
              bottom={line.line_y + '%'}
              style={{
                borderTop: line.istop ? '1px solid white' : '',
                borderBottom: line.istop ? '' : '1px solid white',
                borderRight: line.isright ? '1px solid white' : '',
                borderLeft: line.isright ? '' : '1px solid white',
              }}
            />
          ))}
          {tree.trade_tree.map((node) => (
            <Box
              key={node.id}
              position="absolute"
              left={node.x + '%'}
              bottom={node.y + '%'}
              style={{ marginLeft: '-20px', marginBottom: '-22px' }}
            >
              <Button
                color={
                  station?.id === node.id
                    ? 'blue'
                    : node.is_discovered
                      ? 'good'
                      : 'bad'
                }
                width="40px"
                height="40px"
                tooltip={
                  <Box>
                    <Stack vertical align="center">
                      <Stack.Item>
                        <Box
                          className={classes(['trade32x32', node.icon])}
                          m={2}
                          style={{ transform: 'scale(2)' }}
                        />
                      </Stack.Item>
                      <Stack.Item>{node.name}</Stack.Item>
                    </Stack>
                  </Box>
                }
                tooltipPosition="right"
                onClick={() => act('set_station', { id: node.id })}
              >
                <Box
                  className={classes(['trade32x32', node.icon])}
                  style={{
                    marginLeft: '-3px',
                    marginTop: '4px',
                  }}
                />
              </Button>
            </Box>
          ))}
        </Stack.Item>
        <Stack.Item
          textAlign="left"
          grow
          p={1}
          style={{
            background: 'rgba(0, 0, 0, 0.2)',
            borderRadius: '5px',
          }}
        >
          {station ? (
            <Stack vertical>
              <Stack.Item>
                <Box bold>Name</Box>
                {station.name}
              </Stack.Item>
              <Stack.Item>
                <Box bold>Description</Box>
                {station.desc}
              </Stack.Item>
              <Stack.Item>
                <Box bold>Favor</Box>
                {station.favor} / {station.favor_needed}
              </Stack.Item>
            </Stack>
          ) : (
            <Box color="average">No Station Selected</Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
