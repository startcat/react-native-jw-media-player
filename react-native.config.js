const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { },
      android: {
        packageImportPath: 'import com.appgoalz.rnjwplayer.RNJWPlayerPackage;',
        packageInstance: 'new RNJWPlayerPackage()',
      },
    },
  },
};
