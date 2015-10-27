x�Xmo�H���CЁ��4I/�R�B��B�%>Pd9�&�d�Z����7����K/��}�Pwwv^�gfv�i,��9���w�R>�4�7�=z�G|�H�`&$���\�c% S,���1͔n{��L��2�/48AZϟ﷛�C8��0�yȤڿb���{\��f�����#���]J�+�E�������͓s�γ{��(�q��c�kΥ�R���RF���Ҁ2|nC��B�q�8��=�d�$����)?6YD
2�o�b��g(��aï�q�d�5�FW fFJ�h�� H���1�w�؏&�4m��r\?�#{lqW��^����9��H�(FU��0i�6�F�M|2� �@��Q���RW�|���`�X���<��)cP"$*�����`"E�p���4f	�e�)�/D�IS��=C�#���TH�Q����g��t�3�~l��?�tbv�b��?g��r�����jR
��"�
� ����!��֌���R�*�.$�7$�L��Ѹ] �N�^j�cXH�fZᡥ��R_�	� �M���͈hVa�
���6�'N��AE�:������M�m" �K`(�J���YE��̏�QǹQXo��K��'�ˤ3�~�S"������4��n.��?�6�,1A�ဨ��=�����0"�Ԙ�q�RgE��&�&fE`Vg<F�JH�׃a�ҐZۊ�:ʇ8�6�7�ee��$D��(y��o<e@'�w*#�g�!��=$�����s����a���%�pV��J���' ��'H��|Ψ�l���\�+,g[��`�q4�l!dL��.�[�K�`�`�a�D)�?����c���K�ղS�}aQ2)�ld��7T��za���F�8P�����;������cJ����]h޵I�a����=���7��]w��^��g�'j�"�6:�]6F��o6�M���YOFl�����e���m�]�Z��X�I�wma�q��
ͺU��,�a�o�O�,���y������A���G u8�)���۴�*�\�n����^�(H�R9���4Y�P�9�����դ�xg����;�t�%V�8��`��,�Ȥ��r��VI�T��p��,�*Bm�ݴ]��=�U�?����	-M�8S����$���D����x�L����z�0Ǔ��7~wu�v4��JKE)F��ԛ��W8$TtV�Y1`���Rw����؞q��K)�oKH4}�>�+���<�;��J�GսMm�ԅ>�D�8�yڟ�?���,�V�pk��l�s�)��ق�PCGkpR*�H�s�\��9�l�{�Z?Ͼ��� ǥj�+�mCi��6a*+�ǆ�J�;���6���~��B��C�(h��[�+[�X��N�-������+R|����/e۝�O���n��M�K�j�z�w��F���2�EZ6�V+=q�m�]��h.���[����� -�g��t��t�����	�zO1u�#7����QH��U���I������@`��M��lT�'�� ���o����4U�~��eH\��w�
sm����ʪ@58�n��F���Rx� �ܬ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     package org.opencv.android;

import java.io.File;
import java.util.StringTokenizer;

import org.opencv.core.Core;
import org.opencv.engine.OpenCVEngineInterface;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.net.Uri;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

class AsyncServiceHelper
{
    public static boolean initOpenCV(String Version, final Context AppContext,
            final LoaderCallbackInterface Callback)
    {
        AsyncServiceHelper helper = new AsyncServiceHelper(Version, AppContext, Callback);
        Intent intent = new Intent("org.opencv.engine.BIND");
        intent.setPackage("org.opencv.engine");
        if (AppContext.bindService(intent, helper.mServiceConnection, Context.BIND_AUTO_CREATE))
        {
            return true;
        }
        else
        {
            AppContext.unbindService(helper.mServiceConnection);
            InstallService(AppContext, Callback);
            return false;
        }
    }

    protected AsyncServiceHelper(String Version, Context AppContext, LoaderCallbackInterface Callback)
    {
        mOpenCVersion = Version;
        mUserAppCallback = Callback;
        mAppContext = AppContext;
    }

    protected static final String TAG = "OpenCVManager/Helper";
    protected static final int MINIMUM_ENGINE_VERSION = 2;
    protected OpenCVEngineInterface mEngineService;
    protected LoaderCallbackInterface mUserAppCallback;
    protected String mOpenCVersion;
    protected Context mAppContext;
    protected static boolean mServiceInstallationProgress = false;
    protected static boolean mLibraryInstallationProgress = false;

    protected static boolean InstallServiceQuiet(Context context)
    {
        boolean result = true;
        try
        {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(OPEN_CV_SERVICE_URL));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        }
        catch(Exception e)
        {
            result = false;
        }

        return result;
    }

    protected static void InstallService(final Context AppContext, final LoaderCallbackInterface Callback)
    {
        if (!mServiceInstallationProgress)
        {
                Log.d(TAG, "Request new service installation");
                InstallCallbackInterface InstallQuery = new InstallCallbackInterface() {
                private LoaderCallbackInterface mUserAppCallback = Callback;
                public String getPackageName()
                {
                    return "OpenCV Manager";
                }
                public void install() {
                    Log.d(TAG, "Trying to install OpenCV Manager via Google Play");

                    boolean result = InstallServiceQuiet(AppContext);
                    if (result)
                    {
                        mServiceInstallationProgress = true;
                        Log.d(TAG, "