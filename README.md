# MentorChain

A decentralized professional mentorship hours tracking and recognition platform for incentivizing knowledge sharing on Stacks blockchain.

## Features

- Mentorship hour tracking with specialization-based validation
- Professional mentor recognition and reward system
- Specialization approval and management system
- Contribution-based recognition point calculation
- Comprehensive mentorship program statistics

## Smart Contract Functions

### Public Functions
- `launch-mentorship-program` - Initialize mentorship tracking program
- `approve-specialization` - Approve specialization for tracking (coordinator only)
- `log-mentorship-hours` - Register mentorship hours with specialization
- `calculate-recognition-points` - Calculate recognition points (coordinator only)
- `claim-mentorship-recognition` - Claim mentorship recognition rewards

### Read-Only Functions
- `get-mentorship-hours` - Get mentor's total hours
- `get-mentor-specialization` - Get mentor's specialization
- `get-total-mentorship-hours` - Get total program hours
- `is-specialization-approved` - Check specialization approval status
- `get-program-stats` - Get comprehensive program statistics

## Specializations
Technology, Business, Healthcare, Education, Finance, Marketing, etc.

## Usage

Deploy the contract to create a mentorship tracking system where professionals can log mentoring hours, earn recognition, and contribute to knowledge sharing initiatives.

## License

MIT