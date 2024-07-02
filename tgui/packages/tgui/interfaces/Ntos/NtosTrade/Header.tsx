import { useBackend } from 'tgui/backend';
import { Box, Button, ProgressBar, Section, Table } from 'tgui/components';

import { Data } from './data';

export const NtosTradeHeader = (props) => {
  const { act, data } = useBackend<Data>();

  const { account, prg_screen, sending, prg_type, receiving } = data;

  return (
    <Section style={{ borderRadius: '5px' }}>
      <Table>
        <Table.Row>
          <Table.Cell collapsing>
            <Button onClick={() => act('prg_screen')}>
              {prg_screen ? 'To Merchants' : 'To Trade Screen'}
            </Button>
          </Table.Cell>
          <Table.Cell collapsing>
            <Button icon="link" onClick={() => act('set_account')}>
              {account ? account.name : 'Account'}
            </Button>
            {!!account && (
              <Button
                color="bad"
                icon="times"
                onClick={() => act('clear_account')}
              />
            )}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            {sending?.ready ? (
              <>
                <Button icon="file-export" onClick={() => act('export')}>
                  Export
                </Button>
                <Button
                  icon="suitcase"
                  onClick={() => act('offer_fulfill_all')}
                >
                  Fulfill
                </Button>
              </>
            ) : sending?.time_start ? (
              <Box inline color="average">
                Exporter Recharging
              </Box>
            ) : (
              <Box inline color="bad">
                No Sending Beacon Found
              </Box>
            )}
          </Table.Cell>
        </Table.Row>
        {prg_type === 'master' && (
          <Table.Row>
            <Table.Cell collapsing>
              <Button
                icon="link"
                onClick={() => act('set_receiving')}
                maxWidth={25}
                selected={!!receiving?.id}
                tooltip={receiving?.id || 'Not Connected'}
                tooltipPosition="bottom"
              >
                Receiving Beacon
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                icon="link"
                onClick={() => act('set_sending')}
                maxWidth={25}
                selected={!!sending?.id}
                tooltip={sending?.id || 'Not Connected'}
                tooltipPosition="bottom"
              >
                Sending Beacon
              </Button>
            </Table.Cell>
            <Table.Cell collapsing verticalAlign="top">
              {sending ? (
                <ProgressBar
                  color={sending.ready ? 'good' : ''}
                  value={sending.ready ? 1 : sending.time_elapsed}
                  minValue={0}
                  maxValue={sending.ready ? 1 : sending.time_max}
                />
              ) : (
                <ProgressBar value={0} color="bad" minValue={0} maxValue={1}>
                  ???
                </ProgressBar>
              )}
            </Table.Cell>
          </Table.Row>
        )}
      </Table>
    </Section>
  );
};
