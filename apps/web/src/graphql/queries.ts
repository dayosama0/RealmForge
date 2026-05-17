export const PROTOCOL_ACTIVITY_QUERY = `
  query getProtocolActivity {
    craftEvents(first: 10, orderBy: timestamp, orderDirection: desc) {
      id
      player { address }
      itemId
      timestamp
    }
    swapEvents(first: 10, orderBy: timestamp, orderDirection: desc) {
      id
      player { address }
      amountIn
      amountOut
      timestamp
    }
  }
`;
