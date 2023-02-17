import { Logger } from '@nestjs/common';
import { readFileSync } from 'fs';
import * as yaml from 'js-yaml';
import { join } from 'path';

const YAML_CONFIG_FILENAME = 'config.yaml';

export default () => {
  const config = yaml.load(
    readFileSync(join(__dirname, YAML_CONFIG_FILENAME), 'utf8'),
  ) as Record<string, any>;

  Logger.verbose(JSON.stringify(config))

  // Override config with environment variables
  // First get the first level of preperty in the config
  // Then get the second level of properties in the config and override with environment variables
  for (const prop in config) {
    const levelTwo = config[prop];
    for (const prop2 in levelTwo) {
      Logger.verbose(`Checking for environment variable ${prop}.${prop2}`)
      const envVar = process.env[prop + '.' + prop2];
      if (envVar) {
        Logger.log(
          `Overriding config value ${prop}.${prop2} with environment variable ${envVar}`,
        );
        config[prop][prop2] = envVar;
      }
    }
  }

  Logger.verbose(JSON.stringify(process.env))

  return config;
};
