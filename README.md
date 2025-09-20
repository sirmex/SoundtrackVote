# SoundtrackVote

A community music curation system for shared listening experiences built on the Stacks blockchain using Clarity smart contracts.

## Description

SoundtrackVote is a decentralized platform that enables communities to collaboratively curate music tracks for shared playlists and listening sessions. Users can submit tracks, vote on submissions, and automatically feature popular tracks based on community consensus.

## Features

- **Track Submission**: Users can submit music tracks with title and artist information
- **Democratic Voting**: Community members can vote for their favorite tracks
- **Automatic Featuring**: Tracks automatically become "featured" when they reach the minimum vote threshold (10 votes)
- **Vote Management**: Users can add or remove their votes for tracks
- **Spam Prevention**: Maximum of 5 track submissions per user to prevent spam
- **Featured Track Tracking**: Separate tracking system for featured tracks with timestamps
- **Administrative Controls**: Contract owner can pause/unpause the system
- **Transparent Governance**: All voting and submission data is publicly readable

## Technical Specifications

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity v2
- **Epoch**: 2.5
- **Contract Version**: 1.0.0
- **Minimum Votes for Featured Status**: 10 votes
- **Maximum User Submissions**: 5 tracks per user

### Data Structures

- **Tracks**: Store track metadata including title, artist, submitter, vote count, and featured status
- **User Votes**: Track which users have voted for which tracks
- **User Submissions**: Monitor submission counts to prevent spam
- **Featured Tracks**: Dedicated storage for featured tracks with timestamps

## Installation

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) - For running tests
- [Stacks Wallet](https://www.hiro.so/wallet) - For interacting with the contract

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/SoundtrackVote.git
   cd SoundtrackVote
   ```

2. Navigate to the contract directory:
   ```bash
   cd SoundtrackVote_contract
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Run tests:
   ```bash
   npm test
   ```

## Usage Examples

### Submitting a Track

```clarity
(contract-call? .SoundtrackVote submit-track "Bohemian Rhapsody" "Queen")
```

### Voting for a Track

```clarity
(contract-call? .SoundtrackVote vote-for-track u1)
```

### Removing a Vote

```clarity
(contract-call? .SoundtrackVote remove-vote u1)
```

### Reading Track Information

```clarity
(contract-call? .SoundtrackVote get-track u1)
```

### Checking if User Voted

```clarity
(contract-call? .SoundtrackVote has-user-voted 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u1)
```

## Contract Functions Documentation

### Public Functions

#### `submit-track`
- **Parameters**: `title` (string-ascii 100), `artist` (string-ascii 100)
- **Returns**: Track ID (uint) on success
- **Description**: Submits a new track for community voting
- **Restrictions**: Maximum 5 submissions per user, contract must not be paused

#### `vote-for-track`
- **Parameters**: `track-id` (uint)
- **Returns**: Object with track-id and featured status
- **Description**: Casts a vote for a specific track
- **Restrictions**: One vote per user per track, contract must not be paused

#### `remove-vote`
- **Parameters**: `track-id` (uint)
- **Returns**: Object with track-id and unfeatured status
- **Description**: Removes a user's vote from a track
- **Restrictions**: User must have previously voted, contract must not be paused

#### `set-contract-pause`
- **Parameters**: `paused` (bool)
- **Returns**: Boolean indicating pause status
- **Description**: Pauses or unpauses the contract (admin only)
- **Restrictions**: Only contract owner can execute

### Read-Only Functions

#### `get-track`
- **Parameters**: `track-id` (uint)
- **Returns**: Track information object or none
- **Description**: Retrieves complete track information

#### `has-user-voted`
- **Parameters**: `user` (principal), `track-id` (uint)
- **Returns**: Boolean indicating if user has voted
- **Description**: Checks if a specific user has voted for a track

#### `get-user-submission-count`
- **Parameters**: `user` (principal)
- **Returns**: Number of tracks submitted by user
- **Description**: Returns the submission count for a user

#### `get-total-tracks`
- **Returns**: Total number of tracks in the system
- **Description**: Gets the total count of submitted tracks

#### `is-track-featured`
- **Parameters**: `track-id` (uint)
- **Returns**: Boolean indicating featured status
- **Description**: Checks if a track is currently featured

#### `is-contract-paused`
- **Returns**: Boolean indicating if contract is paused
- **Description**: Checks the current pause status of the contract

#### `get-contract-owner`
- **Returns**: Principal of the contract owner
- **Description**: Returns the contract owner's address

#### `get-min-votes-for-featured`
- **Returns**: Minimum votes required for featuring (10)
- **Description**: Returns the threshold for featured status

## Deployment Guide

### Local Development (Devnet)

1. Start Clarinet console:
   ```bash
   clarinet console
   ```

2. Deploy contract:
   ```clarity
   ::deploy_contracts
   ```

### Testnet Deployment

1. Configure testnet settings in `settings/Testnet.toml`

2. Deploy to testnet:
   ```bash
   clarinet deployments generate --testnet
   clarinet deployments apply --testnet
   ```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`

2. Deploy to mainnet:
   ```bash
   clarinet deployments generate --mainnet
   clarinet deployments apply --mainnet
   ```

## Security Notes

### Access Controls
- Only the contract owner can pause/unpause the contract
- Users can only vote once per track
- Users are limited to 5 track submissions to prevent spam

### Data Validation
- Track titles and artist names must be non-empty strings
- All user inputs are validated before processing
- Vote counts are properly managed to prevent underflow/overflow

### Error Handling
The contract implements comprehensive error handling with specific error codes:
- `u100`: Owner-only function called by non-owner
- `u101`: Track not found
- `u102`: User has already voted for this track
- `u103`: Insufficient votes (cannot remove vote)
- `u104`: Track already exists
- `u105`: Invalid input (empty title or artist)
- `u106`: Contract is paused
- `u107`: User has reached maximum submissions (5)
- `u108`: User has not voted for this track

### Best Practices
- Always check function return values for errors
- Verify contract pause status before interactions
- Monitor featured status changes for tracks
- Use read-only functions for data queries to avoid transaction fees

### Potential Risks
- The contract owner has the power to pause all operations
- No mechanism exists to remove inappropriate content once submitted
- Vote manipulation is possible if users control multiple addresses
- No time limits on voting or track submission periods

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or contributions, please open an issue on the GitHub repository or contact the development team.